# Nomics

[Nomics](https://p.nomics.com/about) is an API-first cryptoasset data company delivering professional-grade market data APIs to institutional crypto investors & exchanges. This gem provides Ruby bindings to its V1 API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nomics'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install nomics

## Usage

First, configure Nomics. You can use the `NOMICS_API_KEY` env var or using a block:

```ruby
Nomics.configure do |config|
  # Get an API key at https://p.nomics.com/pricing
  # This defaults to ENV['NOMICS_API_KEY']
  config.api_key = 'abcd1234'.freeze

  # If you have a free API key that is limited to one call per second,
  # you can add 2 seconds before network calls:
  config.wait_time_in_between_calls = 2
end
```

### Getting currency data

Create a currency object and fetch some data on it
```ruby
btc = Nomics::Currency.new('BTC') # also supports symbols like Nomics::Currency.new(:BTC)
```

Let's see some data!
```ruby
btc.price
btc.name
```

Get all the known attributes (casted for convenience) for a given currency:
```ruby
btc.attributes
```
You can reload the data from the Nomics API with a single call. Here's how you'd get an up-to-date price:
```ruby
btc.reload.price
```

If a currency cannot be found, it will raise an error (once we fetch any data):
```ruby
bazinga = Nomics::Currency.new('BAZINGA')
bazinga.price
# => Cannot find currency with id: BAZINGA (Nomics::UnknownCurrencyError)
```

### Fetching multiple currencies at once

You can fetch multiple currencies using a single call and fetch all attributes:

```ruby
currencies = Nomics::Currencies.new(*%w[BTC XRP ETH])
currencies.map &:attributes
```

If you want to view a specific set of attributes for the currencies provided, you can map over them:

```ruby
currencies = Nomics::Currencies.new(*%w[ETH BTC])

currencies.map &:circulating_supply
currencies.map &:name
currencies.map &:symbol
currencies.map &:price
```

Alternatively you simply just pluck these (similar to how ActiveRecord works)

```ruby
currencies.pluck :circulating_supply, :name, :symbol, :price
```

### Retrieving currencies in given fiat

Retrieving a specific cryptocurrency in a specific fiat currency can also be done. This will quote ticker price, market cap, and volume in the specified currency:

```ruby
btc_in_zar = Nomics::Currency.new('BTC', convert: 'EUR')
eth_in_usd = Nomics::Currency.new('ETH', convert: 'USD')
eth_in_usd = Nomics::Currency.new('ETH') # convert defaults to USD
```

### Calculating the price of one cryptocurrency from another

Advanced calculations are yet under consideration for this gem, but you can calculate prices in relation to their dollar value. For example:

```ruby
btc_price_in_usd = Nomics::Currency.new('BTC').price.to_f # Nomics API defaults to USD
eth_price_in_usd = Nomics::Currency.new('ETH').price.to_f # Nomics API defaults to USD

eth_price_in_btc = eth_price_in_usd / btc_price_in_usd
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/attilagyorffy/nomics.rb.
