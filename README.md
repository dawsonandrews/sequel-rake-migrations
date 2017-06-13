 # Sequel::Rake::Migrations

Migration Rake tasks for [Sequel](http://sequel.jeremyevans.net/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-rake-migrations'
```

And then execute:

    $ bundle

Require the tasks at the top of your Rakefile

```ruby
require "sequel/rake/migrations/tasks"
```

## Usage

Sequel is loaded with DATABASE_URL and TEST_DATABASE_URL environment variables. `ENV["APP_ENV"]` is used to determine current environment ([sinatra#984](https://github.com/sinatra/sinatra/pull/984)).

```ruby
DB = Sequel.connect(ENV["APP_ENV"] == "test" ? ENV["TEST_DATABASE_URL"] : ENV["DATABASE_URL"])
```

### Available Rake Tasks

```sh
# Create dev + test databases
$ bin/rake db:create

# Create a migration
$ bin/rake db:create_migration["create_accounts"]

# Run migrations
$ bin/rake db:migrate
$ bin/rake db:migrate APP_ENV=test

# Rollback
$ bin/rake db:rollback
$ bin/rake db:rollback APP_ENV=test
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dawsonandrews/sequel-rake-migrations.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
