# Unofficial Ruby client for the Spond API

This gem provides an unofficial Ruby client for the Spond API, allowing you to interact with Spond platform for managing sports clubs, teams and events programmatically.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add spond

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install spond

## Usage

Authentication set env vars:

    ENV["SPOND_EMAIL"]
    ENV["SPOND_PASSWORD"]

Authentication happens transparently when these environment variables are set.

You can also authenticate explicitly:

    client = Spond::Client.new(
      email: "your-email@example.com",
      password: "your-password"
    )
    Spond.client = client

### Working with the current user

```ruby
# Get the current user's profile information
profile = Spond.profile
```

### Working with groups

```ruby
# Get all groups the user is a member of
groups = Spond.groups

# Access group information
groups.each do |group|
  puts "Group: #{group.name} (ID: #{group.id})"
end
```

### Working with events

```ruby
# Get all events for the user
events = Spond.events

# Filter events
future_events = Spond::Event.where(maxEndTimestamp: Time.now)

# Get events for a specific group
group_events = Spond::Event.for_group("group-id-here")

# Access event details
event = events.first
puts "Event: #{event.heading}"
puts "Start time: #{event.startTimestamp}"

# Get event comments
comments = event.comments
comments.each do |comment|
  puts "Comment: #{comment.text}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `lib/spond/version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gbp/spond-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gbp/spond-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the unofficial Ruby client for the Spond API project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gbp/spond-ruby/blob/main/CODE_OF_CONDUCT.md).
