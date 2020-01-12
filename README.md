# FlexValidations

Object oriented validations gem with descriptive messages

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flex_validations'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install flex_validations

## Usage

```ruby
integer.validate(1).success? #=> true
integer.validate("foo").fail? #=> true

case 1
when integer
  puts "This is integer"
when string
  puts "This is string"
end

[1, "1.5", 2, 2.3].select(&integer) #=> [1, 2]

puts integer
#=> value.is_a?(Integer) should succeed

puts integer.validate(1)
#=> 1.is_a?(Integer) succeed

puts integer.validate("foo")
#=> "foo".is_a?(Integer) failed
```

### Simple predicate

```ruby
positive = FlexValidations::Predicate.new(:positive?)
integer = FlexValidations::Predicate.new(:is_a?, Integer)

string = FlexValidations::Predicate.new(:is_a?, String)
present = FlexValidations::Predicate.new(:present?)
```

### Chain

```ruby
short = FlexValidations::Chain.new \
          FlexValidations::Call.new(:length),
          FlexValidations::Predicate.new(:<, 256)
```

### And

```ruby
positive_integer = FlexValidations::And.new(integer, positive)
title = FlexValidations::And.new(string, present, short)
```

### Or

```ruby
subtitle = FlexValidations::Or.new \
             FlexValidations::Predicate.new(:nil?),
             title
```

### Decoration

```ruby
have_keys = lambda do |*keys|
  FlexValidations::Chain.new \
    FlexValidations::Call.new(:keys),
    FlexValidations::Decorate.new(Set),
    FlexValidations::Predicate.new(:==, Set.new(keys))
end

hash_of = lambda do |attrs|
  FlexValidations::And.new(
    *attrs.map do |key, validation|
      FlexValidations::Chain.new \
        FlexValidations::Call.new(:[], key),
        validation
    end
  end
end

product =
  FlexValidations::And.new \
    have_keys["id", "title"],
    hash_of[
      "id" => positive_integer,
      "title" => title,
      "subtitle" => subtitle
    ]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryBochkarev/validations.

## Authors

- [Dmitry Bochkarev](email:dimabochkarev@gmail.com) - original author
- [Korotaev Danil](https://github.com/cynek) - gem name


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
