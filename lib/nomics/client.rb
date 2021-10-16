require 'uri'
require 'net/http'
require 'json'
module Nomics
  class Client

    # NOMICS_BASE_URL = "https://api.nomics.com"

    def get(path, params = {})
      params.merge!(key: api_key)

      uri = URI::HTTPS.build(host: 'api.nomics.com', path: path, query: URI.encode_www_form(params))

      wait_if_necessary
      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPSuccess
        JSON.parse response.body
      when Net::HTTPUnauthorized
        raise HTTPAuthorizationError.new(response.body)
      when Net::HTTPServerError
        raise APIServerError.new(response.body)
      else
        raise UnhandledError.new(response.body)
      end
    end

  private

    def api_key
      ::Nomics.configuration.api_key || raise(HTTPAuthorizationError, "Missing API key. Forgot to set ENV['NOMICS_API_KEY'] or Nomics.configuration.api_key?")
    end

    # Nomics.com’s free plan allows for 1 request per second. This allows us to wait in between calls.
    # TODO: Rescue from the specific nomics authorization error and implement automatic waiting in between calls
    def wait_if_necessary
      if seconds = ::Nomics.configuration.wait_time_in_between_calls
        sleep seconds
      end
    end
  end
end
