# Jason::Math

A Math gem.

Not production ready. The eventual goal is to underpin with performant C code, probably built from
my `red` OS abstraction.

This library may be useful, at this time, for educational purposes, as the pure Ruby algorithms are typically closer to English.

I use this library to complete challenges on various platforms. Sorry about the self-indulgent naming,
I wanted to simply call the gem `Math` and that namespace was obviously taken.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jason-math', git: 'https://github.com/jasoncolburne/jason-math', branch: 'main'
```

And then execute:

    $ bundle

To update in the future, use:

    $ bundle update

## Usage

Here is an example of a solution for https://projecteuler.net/problem=12

```ruby
require 'rubygems'
require 'bundler/setup'
require 'jason/math'

n = 1
while true do
  t = Math.polygonal_number(3, n)
  break if t.divisors.count > 500
  n += 1
end

puts Math.polygonal_number(3, n)
```

This gem monkeypatches several core classes. If this is not desirable to you, try something like this (the same code without the convenience methods):

```ruby
require 'rubygems'
require 'bundler/setup'
require 'jason/math/number_theory'

n = 1
while true do
  t = Jason::Math::NumberTheory.polygonal_number(3, n)
  break if Jason::Math::NumberTheory.divisors(t).count > 500
  n += 1
end

puts Jason::Math::NumberTheory.polygonal_number(3, n)
```

The only caveat here is that I may have used some of the convenience methods within the library code itself, meaning the gem may require a bit of refactoring to work correctly. If you notice a `NoMethodError` on `Math`, `Integer`, `Array`, `Set` or `Hash` please send me steps to reproduce.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. Do not release this gem yet. It is still under development. If you make a useful modification, consider creating a pull request.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jasoncolburne/jason-math. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jason::Math project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jasoncolburne/jason-math/blob/master/CODE_OF_CONDUCT.md).
