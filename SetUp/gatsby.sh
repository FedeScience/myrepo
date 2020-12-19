#!/usr/bin/bash
#@ https://www.gatsbyjs.com/docs/how-to/local-development/gatsby-on-linux/
sudo apt update
sudo apt -y upgrade
sudo apt install curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
nvm install --lts
npm install --global gatsby-cli
gatsby new my-first-gatsby-site https://github.com/gatsbyjs/gatsby-starter-default
gatsby new my-first-gatsby-blog https://github.com/gatsbyjs/gatsby-starter-blog