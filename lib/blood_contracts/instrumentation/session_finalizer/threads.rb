module BloodContracts
  module Instrumentation
    module SessionFinalizer
      module Threads
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
