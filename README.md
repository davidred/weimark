# Weimark

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/weimark`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'weimark'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install weimark

## Usage

```
require 'weimark'

# Replace email, password, and agents_email (optional) with your own credentials
@client = Weimark::Client.new(email: 'david@example.com', password: '1234567890')

# Or default to ENV variables set in your application
ENV['WEIMARK_EMAIL'] = 'david@example.com'
ENV['WEIMARK_PASSWORD'] = '1234567890'
ENV['AGENTS_EMAIL'] = 'david@example.com'

@client = Weimark::Client.new

# Get an application by application ID
@client.get('987654321')

# Create a new application
@client.post({fname: 'JONATHAN', lname: 'CONSUMER', dob: '01/05/1987', gender: 'male', ssn: '485774859', streetnumber: '236', streetname: 'BIRCH', streettype: 'S', city: 'BURBANK', country: 'USA', suite: '1TEST', zip: '91502'})
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidred/weimark.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
