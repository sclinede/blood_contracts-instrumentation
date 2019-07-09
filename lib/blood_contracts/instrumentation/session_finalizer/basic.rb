# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    module SessionFinalizer
      # Basic implementation of Session finaliazer
      module Basic
        # Run the instruments against the session in a loop
        # Pros:
        #   - simplest, obvious logic
        # Cons:
        #   - failure in one instrument affects the others
        #
        # @param instruments [Array<Instrument>] list of Instruments to run
        #   against the session
        # @param session [Session] object that hold information about matching
        #   process, argument for Instrument#call
        #
        # @return [Nothing]
        #
        def self.finalize!(instruments, session)
          instruments.each { |i| i.call(session) }
        end
      end
    end
  end
end
