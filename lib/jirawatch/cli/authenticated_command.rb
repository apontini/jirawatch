require 'jirawatch/jira/provider'

module Jirawatch
  module CLI
    module AuthenticatedCommand

      def self.included(base)

        def base.method_added(name)
          if name.eql? :call and not method_defined? :alias_call
            alias_method :alias_call, :call
            define_method(:call) do |*args, &block|
              @jira_account = Jirawatch::Jira::Provider.login
              send :alias_call, *args
            end
          end
        end

      end
    end
  end
end

