module Nomics
  class Currencies
    include Enumerable

    def initialize(*currencies)
      @currencies = currencies.map { |symbol| Currency.new(symbol) }
    end

    def each
      @currencies.map { |currency| yield currency }
    end

    def last
      @currencies.last
    end

    def pluck(*attributes)
      if attributes.one?
        map { |currency| currency.send(attributes.first) }
      else
        map do |currency|
          [].tap do |data|
            attributes.each { |attribute| data << currency.send(attribute) }
          end
        end
      end
    end

    def reload
      @currencies.each &:reload
    end
  end
end
