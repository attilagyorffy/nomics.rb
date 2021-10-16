# frozen_string_literal: true

require_relative "nomics/version"

module Nomics
  class HTTPAuthorizationError < StandardError; end
  class APIServerError < StandardError; end
  class UnknownCurrencyError < StandardError; end
  class UnhandledError < StandardError; end

  autoload(:Configuration, 'nomics/configuration')
  autoload(:Client, 'nomics/client')
  autoload(:Currency, 'nomics/currency')
  autoload(:Currencies, 'nomics/currencies')

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
