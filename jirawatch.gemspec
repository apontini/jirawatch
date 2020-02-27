lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jirawatch/info'

Gem::Specification.new do |s|
  s.name        = 'jirawatch'
  s.version     = Jirawatch::Info::VERSION
  s.date        = '2020-02-27'
  s.summary     = "Jira time tracker"
  s.description = "A simple way to track jira issues time"
  s.authors     = ["Alberto Pontini"]
  s.email       = 'alberto.pontini@gmail.com'
  s.files       = `git ls-files`.split($/)

  s.add_dependency "dry-cli"
end
