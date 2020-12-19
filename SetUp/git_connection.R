#@ https://happygitwithr.com/hello-git.html#hello-git
## install if needed (do this exactly once):
## install.packages("usethis")

library(usethis)
use_git_config(user.name = "Jane Doe", user.email = "jane@example.org")
usethis::create_github_token()
