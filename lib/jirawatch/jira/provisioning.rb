require 'jirawatch/jira/account'

module Jirawatch
  module Jira
    module Provisioning
      @@config_path = File.expand_path "~/.jirawatch"
      @@login_file = "login"

      def login(username = nil, token = nil)
        if username.nil? or token.nil?
          puts 'Logging in from file...'
          unless File.exist? @@config_path + "/" + @@login_file
            return nil
          end
          username = "user"
          api_token = "password"
          site = "site"
        else
          puts 'Logging in...'
          username = "user"
          api_token = "password"
          site = "site"
        end

        options = {
            username: username,
            password: api_token,
            site: site,
            auth_type: :basic,
            read_timeout: 120
        }
      end

      def save_credentials(username, token, site)
        File.open(@@config_path + "/" + @@login_file, "w") do |f|
          f.write "#{username}\n#{token}\n#{site}"
        end
      end
    end
  end
end
