module BloodContracts
  module Instrumentation
    module SessionRecording
      module Match
        def match

          result = super
        rescue StandardError => ex
          result = FailedMatch.new(ex, context: @context)
          raise ex
        ensure
          finalize!(result)
        end

        def finalize!(result)
          return if self.class.non_terminal_class

          @session.finish(result)
          @instruments.each { |i| i.after(@session)  }
          Instrumentation.finalize!(@instruments, @session)
        end
      end

      module Inheritance
        def inherited(child)
          instance_variable_set(:@non_terminal_class, true)
          child.prepend Match
          Instrumentation.register_type(child)
          super
        end
      end

      def self.prepended(other)
        other.prepend Match
        class << other
          prepend Inheritance

          def anonymous?
            name.nil?
          end

          def instruments
            return @instruments if defined? @instruments
            reset_instruments!
          end

          def reset_instruments!
            @instruments = Instrumentation.config.select_instruments(name)
          end

          attr_reader :non_terminal_class
        end
      end

      def initialize(*)
        super
        @session = Session.new
        @session.start(self.class.name)

        @instruments = self.class.instruments.to_a.map(&:new)
        @instruments.each { |i| i.before(@session)  }
      end
    end
  end
end
