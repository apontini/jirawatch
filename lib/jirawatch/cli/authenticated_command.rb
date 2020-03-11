require 'jirawatch/jira/provider'

module Jirawatch
  module CLI
    module AuthenticatedCommand
      include Jirawatch::Jira::Provider

      def self.included(base)

        def self.before(*names)
          names.each do |name|
            ObjectSpace.each_object(Class).select { |klass| klass.included_modules.include? self }.each do |klass|
              m = klass.instance_method(name)
              define_method(name) do |*args, &block|
                yield
                m.bind(self).(*args, &block)
              end
            end
          end
        end

        before :call do
          puts "before"
          Jirawatch::Jira::Provider.login
        end

      end
    end
  end
end

