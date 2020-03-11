require 'jirawatch/jira/provisioning'

module Jirawatch
  module CLI
    module AuthenticatedCommand
      include Jirawatch::Jira::Provisioning

      def self.included(base)

        def base.method_added(name)
          if name.eql? :call and not method_defined? :alias_call
            alias_method :alias_call, :call
            define_method(:call) do |*args, &block|
              @jira_account = login
              
              if @jira_account.nil?
                puts "Login infos not found, please use: \n\njirawatch login\n\n"
              else
                send :alias_call, *args
              end
            end
          end
        end

      end
    end
  end
end

