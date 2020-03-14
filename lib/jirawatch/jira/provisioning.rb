require 'jira-ruby'

module Jirawatch
  module Jira
    module Provisioning

      def login(username = nil, token = nil, site = nil)
        if username.nil? or token.nil? or site.nil?

          return nil unless File.exist? Jirawatch.configuration.login_file

          File.open(Jirawatch.configuration.login_file).each_line do |line|
            binding.local_variable_set line.split(' ')[0], line.split(' ')[1]
          end

        end

        options = {
            username: username,
            password: token,
            site: site,
            context_path: '',
            auth_type: :basic,
            read_timeout: 120
        }

        client = JIRA::Client.new(options)
        begin
          # Get some infos to check if login was successful
          client.ServerInfo.all.attrs["baseUrl"]
          return client
        rescue JIRA::HTTPError => e
          puts e.response.body
        rescue StandardError => e
          puts e.message
        end

        nil
      end

      def save_credentials(username, token, site)
        File.open(Jirawatch.configuration.login_file, "w") do |f|
          f.write ["username #{username}", "token #{token}", "site #{site}"].join "\n"
        end
      end
    end
  end
end
