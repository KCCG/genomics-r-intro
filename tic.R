source("build_lesson.R")

get_stage("before_install") %>%
  add_code_step(install.packages("git2r")) %>%
  add_code_step(update.packages(ask = FALSE))

get_stage("install") %>%
  add_code_step(system("python -m pip install update-copyright")) %>%
  add_step(step_install_github("fmichonneau/checker"))

get_stage("deploy") %>%
  add_step(build_lesson()) %>%
  add_step(check_links())

if (ci_on_travis()) {
  # pkgdown documentation can be built optionally. Other example criteria:
  # - `inherits(ci(), "TravisCI")`: Only for Travis CI
  # - `ci()$is_tag()`: Only for tags, not for branches
  # - `Sys.getenv("BUILD_PKGDOWN") != ""`: If the env var "BUILD_PKGDOWN" is set
  # - `Sys.getenv("TRAVIS_EVENT_TYPE") == "cron"`: Only for Travis cron jobs

  ## if there is a tag associated with the push or we are in master, the
  ## lesson gets deployed on gh-pages, and rendered by GitHub
  if (ci()$get_branch() == "master" || ci()$is_tag()) {

    get_stage("before_deploy") %>%
      add_step(step_setup_ssh())

    get_stage("deploy") %>%
      add_step(step_push_deploy(path = "_rendered", branch = "gh-pages"))
  }

}
