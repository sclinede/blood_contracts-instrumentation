# frozen_string_literal: true

require "fiber"

module BloodContracts
  module Instrumentation
    module SessionFinalizer
      # Threads over fibers implementation of Session finaliazer
      class Fibers
        # Error message when fibers pool is not enough to run all the
        # instruments
        STARVATION_MSG = "WARNING! BC::Instrumentation fiber starvation!"

        # Initialize the fibers pool
        #
        # @param pool_size [Integer] number of fibers to use in a single run
        def initialize(pool_size)
          @fibers = pool_size.times.map { create_fiber_with_a_thread }
        end

        # Run the instruments against the session in a loop (each in a separate
        # fiber on separate thread)
        #
        # Pros:
        #   - Each instrument call don't affect the others
        #   - Each instrument run in parallel (up to GIL)
        #   - Runs in parallel to the matching process, so should have
        #     minimum impact on BC::Refined#match speed
        # Cons:
        #   - thread creation have costs
        #   - the pool size is limited, so if you use number of instruments
        #     more the pool size  you have to update Config#finalizer_pool_size
        #     properly
        #
        # @param instruments [Array<Instrument>] list of Instruments to run
        #   against the session
        # @param session [Session] object that hold information about matching
        #   process, argument for Instrument#call
        #
        # @return [Nothing]
        #
        def finalize!(instruments, session)
          instruments.each do |instrument|
            raise STARVATION_MSG unless (fiber = @fibers.shift)

            fiber.resume instrument, session if fiber.alive?
          end
        end

        # @private
        #
        # Create a fiber which holds a Thread to run next Instrument#call
        # against the session
        #
        # @return [Fiber]
        protected def create_fiber_with_a_thread
          Fiber.new do |instrument, session|
            loop do
              thread = Thread.new { instrument.call(session) }
              @fibers.unshift Fiber.current
              instrument, session = Fiber.yield
              thread.join
            end
          end
        end
      end
    end
  end
end
