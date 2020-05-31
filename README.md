# Jirawatch
Jirawatch is a simple CLI tool that allows you to track the time you spend on a particular Jira issue without having to access your crowded backlog/kanban.
Tracking time is as simple as typing:
```
jirawatch track ISSUE-873
```
After that, jirawatch will start tracking your time and, once you're done, you can press `Ctrl-c` to stop the time tracking and allow jirawatch to save it into the Jira worklogs of the related issue.
If you need to stop tracking time, just press `Ctrl-p` and then press it again to resume.

## Installation
There's no install script right now unfortunately (it will be coming though!).
For the time being, you need to install Ruby (2.7.0 was used do develop this gem but it should work from 2.1.0 onwards) using [rbenv](https://github.com/rbenv/rbenv).

As a side note, I highly discourage installing Ruby without rbenv and installing rbenv from a package manager (reason is that rbenv packages are severely outdated most of the time), unless you know what you're doing of course!

After that, clone this repository and build this gem using:
```
gem build jirawatch.gemspec
```
and install it with:
```
gem install jirawatch-<gem-version>.gem
```

You should now be good to go!

### With Docker/Podman

You can execute `jirawatch` without installing it on your machine! Jirawatch is available via Docker/Podman too.
To run it just type:
```
docker run apontini/jirawatch
```
and you're good to go!

If you feel like doing everything by yourself it can be built from the repository with:
```
docker build -t <your username>/jirawatch
docker run <your username>/jirawatch # enjoy the magic
```

Keep in mind that you need to setup persistence in order to store Jirawatch's configuration files. You can put in your `.bashrc` or `.zshrc` the following alias:
```
alias jirawatch="docker run --rm -it -v${HOME}/.jirawatch:/root/.jirawatch -v/etc/localtime:/etc/localtime:ro apontini/jirawatch"
```
This will ensure persistence and will not modify your machine with additional packages ;)

## How to use
As I stated before, this is not a complex tool! There are a few commands implemented as of right now:
```
jirawatch version               # Prints the current jirawatch version
jirawatch login                 # Allows to log you in to Jira then saves your credentials if the operation succeeded
jirawatch projects              # Lists all Jira projects
jirawatch issues [project-key]  # Lists every issue related to a project
jirawatch track [issue-key]     # Starts tracking time for an issue
```

You need to register your Jira credentials first, before you can start tracking. Be sure to have a valid API Token for your account (which you can generate at https://id.atlassian.com/manage/api-tokens).
Then use the `login` command and follow the prompt instructions.
If everything is successful, you're good to go!
