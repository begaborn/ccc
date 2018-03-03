require 'json'
require 'net/http'
require_relative 'client/version'

module Bithumb
  class Client
    def initialize(options = {})
      #@api_key = options[:api][:key]
      #@secret_key = conf[:api][:secret]
    end

    def endpoint
      'https://api.bithumb.com/'
    end

    def get(path, params={})
      uri = URI(File.join(endpoint, path))
      uri.query = params.to_query
      parse Net::HTTP.get_response(uri)
    end

    def post(path, params={})
      uri = URI(File.join(endpoint, path))
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true if endpoint.start_with?('https://')
      http.start do |http|
        parse http.request_post(path, params.to_query)
      end
    end

    def ticker(currency_code = 'btc')
      get("public/ticker/#{currency_code}")
    end

    def orderbook(currency_code = 'btc')
      get("public/orderbook/#{currency_code}", {count: 2})
    end

    def parse(response)
      JSON.parse response.body
    rescue JSON::ParserError => e
      raise BitBot::UnauthorizedError, response['warning']
    end
  end
end
