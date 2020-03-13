module Jirawatch
  module Errors
    class CommandFailed < StandardError
      def initialize(msg="Error encountered")
        super(msg)
      end
    end
  end
end
