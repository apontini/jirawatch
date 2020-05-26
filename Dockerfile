FROM ruby:2.7.1-alpine3.11

LABEL maintainer Davide Polonio <poloniodavide@gmail.com>
LABEL description "Simple CLI jira issue time tracker"

COPY . /workdir/
WORKDIR /workdir

RUN apk add --no-cache git \
  && gem build jirawatch.gemspec \
  && gem install jirawatch-"$(ruby -e 'load "lib/jirawatch/info.rb"; puts Jirawatch::Info::VERSION')".gem \
  && rm -rf workdir

ENTRYPOINT ["/usr/local/bundle/bin/jirawatch"]
