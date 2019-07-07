require 'blood_contracts/core'
require 'securerandom'

module BloodContracts
  module Instrumentation
    def configure
      config.tap { |c| yield c }
    end
    module_function :configure

    def register_type(type)
      config.types << type
      type.reset_instruments! unless type.anonymous?
    end
    module_function :register_type

    module_function def finalize!(*args)
      SessionFinalizer.instance.finalize!(*args)
    end

    def config
      @config ||= Config.new
    end
    module_function :config

    require_relative './instrumentation/failed_match.rb'
    require_relative './instrumentation/session.rb'
    require_relative './instrumentation/empty_session.rb'


    require_relative './instrumentation/instrument.rb'
    require_relative './instrumentation/session_finalizer.rb'
    require_relative './instrumentation/session_recording.rb'
    BC::Refined.prepend(SessionRecording)

    require_relative './instrumentation/config.rb'
  end
end
