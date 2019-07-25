# frozen_string_literal: true

require "blood_contracts/core"
require "securerandom"

# Top-level scope for BloodContracts data validation and monitoring tools
module BloodContracts
  # Top-level interface for BloodContracts insturmentation
  module Instrumentation
    module_function

    # Configure the instrumentation by modification of the Config object
    #
    # @yieldparam [Config]
    #
    # @return [Config]
    #
    def configure
      config.tap { |c| yield c }
    end

    # Register type in the config
    #
    # @param type [BC::Refined] which added to the registry
    #
    # @return [Nothing]
    #
    def register_type(type)
      config.types << type
      type.reset_instruments! unless type.anonymous?
    end

    # Select instruments for the type
    #
    # @param type_name [String] used to filter the instruments
    #
    # @return [Array<Instrument>]
    #
    def select_instruments(type_name)
      config.send(:select_instruments, type_name)
    end

    # Resets current instance of Session finalizer
    #
    # @return [#finalize!]
    #
    def reset_session_finalizer!
      config.send(:reset_session_finalizer!)
    end

    # Instrumentation config
    #
    # @return [Config]
    #
    def config
      @config ||= Config.new
    end

    # Resets current instance of Config
    #
    # @return [Nothig]
    #
    def reset_config!
      @config = nil
    end

    require_relative "./instrumentation/failed_match.rb"
    require_relative "./instrumentation/session.rb"

    require_relative "./instrumentation/instrument.rb"
    require_relative "./instrumentation/session_finalizer.rb"
    require_relative "./instrumentation/session_recording.rb"
    BC::Refined.prepend(SessionRecording)

    require_relative "./instrumentation/config.rb"
  end
end

# Alias for top-level BloodContracts instrumentation
BCI = BloodContracts::Instrumentation
