# frozen_string_literal: true

module BloodContracts
  module Instrumentation
    # Prependable module for matching session recording
    module SessionRecording
      # Adds @session initialization to constructor
      def initialize(*)
        super
        self.class.instruments
        @session = self.class.session_klass.new(self.class.name)
      end

      # Wrapper for BC::Refined#match call, to add instrumentaion
      # Usage:
      #   class JsonType < BC::Refined
      #     # now during #match call you will have access to @session
      #     prepend BloodContracts::Instrumentation::Match
      #
      #     def match
      #       context[:parsed] = JSON.parse(value.to_s)
      #       self
      #     end
      #   end
      module Match
        # Wraps original call in session start and finish call
        # Note that @session.finish(result) is called even when
        # exception was raised during the call
        #
        # @return [BC::Refined]
        #
        def match
          @session.start
          self.class.instruments.each { |i| i.before(@session) }

          result = super
        rescue StandardError => e
          result = FailedMatch.new(e, context: @context)
          raise e
        ensure
          finalize!(result)
        end

        # Finish the matching session and delegate finalize to SessionFinalizer
        #
        # @param result [BC::Refined] result of type matching pipeline
        #
        # @return [Nothing]
        #
        def finalize!(result)
          @session.finish(result)
          self.class.instruments.each { |i| i.after(@session) }
          SessionFinalizer.instance.finalize!(self.class.instruments, @session)
        end
      end

      # Modification to inheritance for the session recording
      module Inheritance
        # Register the inherited type and set the session klass same as parent
        #
        # @param child [BC::Refined] class to enhance
        #
        # @return [Nothing]
        #
        def inherited(child)
          child.session_klass = session_klass
          Instrumentation.register_type(child)
          super
        end
      end

      # Modifications in singleton class of BC::Refined
      #
      # @param other [BC::Refined] class to enhance
      #
      # rubocop:disable Metrics/MethodLength
      def self.prepended(other)
        class << other
          prepend Inheritance

          # Class to use as a session (writer)
          #
          # @return [Session]
          #
          attr_writer :session_klass

          # Class to use as a session
          # By default is set to Session
          #
          # @return [Session]
          #
          def session_klass
            @session_klass ||= Session
          end

          # Whether type anonymous or not
          #
          # @return [Boolean]
          #
          def anonymous?
            name.nil?
          end

          # List of instruments for the type
          #
          # @return [Array<Instrument>]
          #
          def instruments
            return @instruments if defined? @instruments

            reset_instruments!
          end

          # Alias for instruments reader
          # See #instruments
          alias setup_instruments instruments

          # Reset the List of instruments for the type
          # Note, that if list of instruments is empty there is no need to
          # init the session, so type is not prepended by Match wrapper
          #
          # @return [Array<Instrument>]
          #
          def reset_instruments!
            @instruments = Instrumentation.select_instruments(name)
          ensure
            prepend(Match) unless @instruments.empty?
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
