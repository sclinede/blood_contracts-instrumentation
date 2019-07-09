# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    module SessionFinalizer
      # Multi-threaded implementation of Session finalizer
      module Threads
        # Run the instruments against the session in a Thread in a loop
        # Pros:
        #   - parallel execution of instruments (up to GIL)
        #   - one failed instrument do not affect the others
        # Cons:
        #   - creating a thread has costs
        #   - do not parallel with the BC::Refined matching, as we need to
        #     finish the threads, join them to main Thread
        #
        # @param instruments [Array<Instrument>] list of Instruments to run
        #   against the session
        # @param session [Session] object that hold information about matching
        #   process, argument for Instrument#call
        #
        # @return [Nothing]
        #
        def self.finalize!(instruments, session)
          threads = instruments.map do |i|
            Thread.new { i.call(session) }
          end
          threads.map(&:join)
        end
      end
    end
  end
end
