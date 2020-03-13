module Jirawatch
  module Utils
    module Messages

      def fail!(message = nil)
        raise Jirawatch::Errors::CommandFailed.new(message)
      end

    end
  end
end
