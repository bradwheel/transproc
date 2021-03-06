[gem]: https://rubygems.org/gems/transproc
[travis]: https://travis-ci.org/solnic/transproc
[gemnasium]: https://gemnasium.com/solnic/transproc
[codeclimate]: https://codeclimate.com/github/solnic/transproc
[coveralls]: https://coveralls.io/r/solnic/transproc
[inchpages]: http://inch-ci.org/github/solnic/transproc

# Transproc [![Join the chat at https://gitter.im/solnic/transproc](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/solnic/transproc)

[![Gem Version](https://badge.fury.io/rb/transproc.svg)][gem]
[![Build Status](https://travis-ci.org/solnic/transproc.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/solnic/transproc.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/solnic/transproc/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/solnic/transproc/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/solnic/transproc.svg?branch=master)][inchpages]

Functional transformations for Ruby. It's currently used as one of the data
mapping backends in [Ruby Object Mapper](http://rom-rb.org).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'transproc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install transproc

## Usage

``` ruby
require 'json'
require 'transproc/all'

# compose transformation functions
include Transproc::Helper

transformation = t(:map_array, t(:symbolize_keys) >> t(:rename_keys, user_name: :user))
transformation >>= t(:wrap, :address, [:city, :street, :zipcode])

# call the function
transformation.call(
  [
    { 'user_name' => 'Jane',
      'city' => 'NYC',
      'street' => 'Street 1',
      'zipcode' => '123' }
  ]
)
# => [{:user=>"Jane", :address=>{:city=>"NYC", :street=>"Street 1", :zipcode=>"123"}}]

# Define your own transformations easily
Transproc.register(:to_json, -> v { JSON.dump(v) })

Transproc(:to_json).call([{ name: 'Jane' }])
# => "[{\"name\":\"Jane\"}]"

# ...or create a module with custom transformations
module MyTransformations
  extend Transproc::Functions

  def load_json(v)
    JSON.load(v)
  end
end

(Transproc(:load_json) >> Transproc(:map_array, Transproc(:symbolize_keys))).call('[{"name":"Jane"}]')
# => [{ :name => "Jane" }]
```

## Credits

This project is inspired by the work of following people:

* [Markus Schirp](https://github.com/mbj) and [morpher](https://github.com/mbj/morpher) project
* [Josep M. Bach](https://github.com/txus) and [kleisli](https://github.com/txus/kleisli) project

## Contributing

1. Fork it ( https://github.com/solnic/transproc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
