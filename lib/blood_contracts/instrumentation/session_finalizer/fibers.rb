module BloodContracts
  module Instrumentation
    module SessionFinalizer
      class Fibers
        def initialize(pool_size)
          @fibers = pool_size.times.map do
            Fiber.new do |instrument, session|
              loop do
                thread = Thread.new do
                  instrument.call(session)
                end
                @fibers.unshift Fiber.current
                instrument, session = Fiber.yield
                thread.join
              end
            end
          end
        end

        STARVATION_MSG = "WARNING! BC::Instrumentation fiber starvation!".freeze
        def finalize!(instruments, session)
          instruments.each do |instrument|
            return STDERR.puts STARVATION_MSG unless (fiber = @fibers.shift)
            fiber.resume instrument, session if fiber.alive?
          end
        end
      end
    end
  end
end
