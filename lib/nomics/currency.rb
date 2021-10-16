require 'time'
require 'bigdecimal'

module Nomics
  class Currency
    ATTTRIBUTES_WITH_TYPES = {
      'id' => :string,
      'currency' => :string,
      'symbol' => :symbol,
      'name' => :string,
      'logo_url' => :string,
      'status' => :string,
      'price' => :number,
      'price_date' => :timestamp,
      'price_timestamp' => :timestamp,
      'circulating_supply' => :number,
      'max_supply' => :number,
      'market_cap' => :number,
      'market_cap_dominance' => :number,
      'num_exchanges' => :number,
      'num_pairs' => :number,
      'num_pairs_unmapped' => :number,
      'first_candle' => :timestamp,
      'first_trade' => :timestamp,
      'first_order_book' => :timestamp,
      'rank' => :number,
      'rank_delta' => :number,
      'high' => :number,
      'high_timestamp' => :timestamp
    }.freeze

    attr_reader :symbol, :quote_currency

    def initialize(symbol, convert: :USD)
      @symbol = symbol.to_s.upcase.to_sym
      @quote_currency = convert.to_s.upcase.to_sym

      ATTTRIBUTES_WITH_TYPES.except('symbol').keys.each do |attribute_name|
        instance_variable_set("@#{attribute_name}", nil)
      end
    end

    def <=>(other_currency)
      name <=> other_currency.name
    end

    ATTTRIBUTES_WITH_TYPES.except('symbol').each do |(attribute_name, attribute_type)|
      define_method(attribute_name) do
        attributes[attribute_name]
      end
    end

    def attributes(reload: false)
      if reload
        @attributes = attributes_with_types data.slice(*ATTTRIBUTES_WITH_TYPES.keys)
      else
        @attributes ||= attributes_with_types data.slice(*ATTTRIBUTES_WITH_TYPES.keys)
      end

      @attributes.each do |(attribute_name, attribute_value)|
        instance_variable_set("@#{attribute_name}", attribute_value)
      end
    end

    def reload
      attributes reload: true
      self
    end

  private

    def attributes_with_types(attributes = {})
      attributes.inject({}) do |typed_attributes, (attribute_key, attribute_value)|
        typed_attributes[attribute_key] = cast value: attribute_value, type: ATTTRIBUTES_WITH_TYPES[attribute_key]

        typed_attributes
      end
    end

    def cast(value:, type:)
      case type
      when :string
        value.to_s
      when :symbol
        value.to_sym
      when :number
        BigDecimal(value)
      when :timestamp
        Time.parse(value)
      else
        raise "Unknown type: #{attribute_type}"
      end
    end

    def data
      client.get('/v1/currencies/ticker', ids: [@symbol], convert: @quote_currency).first || raise(Nomics::UnknownCurrencyError.new("Cannot find currency with id: #{@symbol}"))
    end

    def client
      @client ||= Client.new
    end
  end
end
