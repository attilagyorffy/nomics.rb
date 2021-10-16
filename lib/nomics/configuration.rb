module Nomics
  class Configuration
    attr_accessor :api_key, :wait_time_in_between_calls

    def initialize
      @api_key = ENV['NOMICS_API_KEY']
      @wait_time_in_between_calls = nil
    end
  end
end
