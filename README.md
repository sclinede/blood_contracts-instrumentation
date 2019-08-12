[![Build Status](https://travis-ci.org/sclinede/blood_contracts-instrumentation.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/sclinede/blood_contracts-instrumentation/badges/gpa.svg)][codeclimate]
[![Inch CI](https://inch-ci.org/github/sclinede/blood_contracts-instrumentation.svg?branch=master)][inch_ci]

[gem]: https://rubygems.org/gems/blood_contracts-instrumentation
[travis]: https://travis-ci.org/sclinede/blood_contracts-instrumentation
[codeclimate]: https://codeclimate.com/github/sclinede/blood_contracts-instrumentation
[inch_ci]: https://inch-ci.org/github/sclinede/blood_contracts-instrumentation


# BloodContracts::Instrumentation

Refinement types are implemented in [BloodContracts::Core](https://github.com/sclinede/blood_contracts-core), but in production first of all we have to understand
which types are used and how frequently. In other words we need instrumentation for types.

Let's say, we want to log to STDOUT every match of your Rubygems API contract:
```ruby
BloodContracts::Instrumentation.configure do |cfg|
  # Attach to every BC::Refined ancestor with Rubygems in the name
  cfg.instrument /Rubygems/, lambda { |session|

    # see Session class API at lib/blood_contracts/instrumentation/session.rb
    puts "SID:#{session.id} "\
         "Duration: #{session.finished_at - session.started_at} "\
         "Result: #{session.result_type_name}"
  }
end

```

Welcome, **Instrumentation for BloodContracts**.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blood_contracts-instrumentation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blood_contracts-instrumentation

## Usage

Most of the time you will use only BloodContracts::Instrumentation.configure call. It gives you access to instrumentation
config and adds different instruments to types by name.
First argument is a String or Regex which will used to find relevant Refined type to attach.
The second argument is the actual "instrument".

The simplest instrument is just a lambda with 1 argument _session_, but in advanced case, you could implement "instrument" as a class.

For example, we use [Yabeda](https://github.com/yabeda-rb/yabeda) for instrumentation. So you could introduce Yabeda instrument for that:

```ruby
# config/initializers/contracts.rb

module Contracts
  class YabedaInstrument
    def call(session)
      valid_marker = session.valid? ? "V" : "I"
      result = "[#{valid_marker}] #{session.result_type_name}"
      Yabeda.api_contract_matches.increment(result: result)
    end
  end
end

BloodContracts::Instrumentation.configure do |cfg|
  # Attach to every BC::Refined ancestor with Rubygems in the name
  cfg.instrument /Rubygems.*Contract/, Contracts::YabedaInstrument.new

  # Attach to every BC::Refined ancestor with Github in the name
  cfg.instrument /Github.*Contract/, Contracts::YabedaInstrument.new
end
```

For more details see [Instrument class](lib/blood_contracts/instrumentation/instrument.rb)

Finally, you may want to verify, which instruments are already attached to the type:
```
[1] pry(main)> RubygemsAPI::Contract.instruments
=> [#<Contracts::YabedaInstrument:0x00007fe89ad322c0>, #<Contracts::FailuresInstrument:0x00007fe89ad39e30>]
```

That's pretty much it!

*Uh, oh!* Almost forgot, you could choose the strategy for instrumentation finalizer.
Imagine that you want to write some debug data into DB. In some cases that will affect the performance of your
type matching. To minimize that effect you could try to use Fibers or Threads as simple as:

```ruby
# config/initializers/contracts.rb

BloodContracts::Instrumentation.configure do |cfg|
  # Attach to every BC::Refined ancestor with Rubygems in the name
  cfg.instrument /Rubygems.*Contract/, Contracts::YabedaInstrument.new

  # Attach to every BC::Refined ancestor with Github in the name
  cfg.instrument /Github.*Contract/, Contracts::YabedaInstrument.new

  cfg.finalizer = :fibers # or :threads, or :basic
end
```

See more info about Finalizers here: [Basic](lib/blood_contracts/instrumentation/session_finalizer/basic.rb), [Fibers](lib/blood_contracts/instrumentation/session_finalizer/fibers.rb), [Threads](lib/blood_contracts/instrumentation/session_finalizer/threads.rb)

Enjoy!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sclinede/blood_contracts-instrumentation. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BloodContracts::Instrumentation project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sclinede/blood_contracts-instrumentation/blob/master/CODE_OF_CONDUCT.md).
