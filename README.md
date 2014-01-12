# BitwiseEnum

It extend `Active Record enums` to `OR` values.
It has been implemented in bit operation.

## Installation

Add this line to your application's Gemfile:

    gem 'bitwise_enum'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitwise_enum

## Usage

```
  class User < ActiveRecord::Base
    bitwise_enum role: [ :admin, :worker ]
  end
```

```
user.admin!
user.admin? # => true
user.role   # => "['admin']"

user.admin!
user.admin? # => true
user.not_admin!
user.admin? # => false

user.role = :admin
user.admin? # => true
user.role   # => ['admin']

user.admin!     # => ['admin']
user.reset_role # => nil
user.role = []

User.admin # => SELECT `users`.* FROM `users` WHERE (role & 1 = 1)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
