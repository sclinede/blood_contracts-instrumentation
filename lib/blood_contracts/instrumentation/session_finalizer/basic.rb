module BloodContracts
  module Instrumentation
    module SessionFinalizer
      module Basic
        def self.finalize!(instruments, session)
          instruments.each { |i| i.call(session) }
        end
      end
    end
  end
end
