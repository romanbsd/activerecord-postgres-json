# activerecord-postgres-json

A minimal JSON/JSONB column type support for ActiveRecord 3.2.x
This gem adds the following support:

1. Using json/jsonb column type in migrations, e.g. `add_column :foo, :bar, :json` or `add_column :foo, :bar, :jsonb`
2. json field support in the schema definitions
3. JSON coder for using with the `serialize` class method:

```ruby
class User < ActiveRecord::Base
  serialize :settings, ActiveRecord::Coders::JSON
  serialize :settings, ActiveRecord::Coders::JSON.new(symbolize_keys: true) # for symbolize keys
end

User.first.settings.class # => Hash
User.first.settings[:show_popups] # => true
...
```

## Contributing to activerecord-postgres-json

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 Roman Shterenzon. See LICENSE.txt for
further details.

