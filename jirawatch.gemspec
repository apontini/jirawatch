Gem::Specification.new do |s|
  s.name        = 'jirawatch'
  s.version     = '0.1.0'
  s.date        = '2020-02-27'
  s.summary     = "Jira time tracker"
  s.description = "A simple way to track jira issues time"
  s.authors     = ["Alberto Pontini"]
  s.email       = 'alberto.pontini@gmail.com'
  s.files       = ["lib/jirawatch.rb"]

  s.add_dependency "dry-cli"
end
