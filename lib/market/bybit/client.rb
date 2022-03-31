module Bybit
  class Client
    # Mainnet
    ENDPOINT = 'https://api.bybit.com'.freeze

    attr_accessor :symbol

    def initialize(symbol)
      self.symbol = symbol
    end

    # Place Order
    # https://bybit-exchange.github.io/docs/spot/?console#t-placeactive
    def create_order(side, qty, type, price: nil)
      params = {
        symbol: symbol,
        qty: qty,
        side: side,
        type: type,
      }

      params[:price] = price unless price.to_f.zero?
      post('/spot/v1/order', params)
    end

    # Cancel Order
    # https://bybit-exchange.github.io/docs/spot/?console#t-getactive
    def delete_order(id)
      delete('/spot/v1/order', { orderLinkId: id })
    end

    # Get Order
    # https://bybit-exchange.github.io/docs/spot/?console#t-getactive
    def get_order(id)
      get('/spot/v1/order', { orderLinkId: id })
    end

    # Open Orders
    # https://bybit-exchange.github.io/docs/spot/?console#t-openorders
    def open_orders
      get('/spot/v1/open-orders', { symbol: symbol })
    end

    # Last Traded Price
    # https://bybit-exchange.github.io/docs/spot/?console#t-lasttradedprice
    def price
      get_without_sign('/spot/quote/v1/ticker/price', { symbol: symbol })
    end

    # Get Wallet Balance
    # https://bybit-exchange.github.io/docs/spot/?console#t-balance
    def account
      get('/spot/v1/account')
    end

    private

    def conf
      {
        api: {
          key: ENV['BYBIT_API_KEY'], secret: ENV['BYBIT_API_SECRET'],
        },
      }
    end

    def get_without_sign(path, params={})
      uri = URI(File.join(ENDPOINT, path))
      uri.query = params.to_query
      res = parse(Net::HTTP.get_response(uri))
      if res['ret_code'] != 0
        raise ApiError.new(res)
      end
      res
    end

    def get(path, params={})
      params[:symbol] ||= symbol
      params[:api_key] ||= conf[:api][:key]
      params[:timestamp] ||= Time.now.to_i * 1000

      sign = get_signature(params)
      params[:sign] = sign

      uri = URI(File.join(ENDPOINT, path))
      uri.query = params.to_query
      res = parse(Net::HTTP.get_response(uri))
      if res['ret_code'] != 0
        raise ApiError.new(res)
      end

      res
    end

    def post(path, params={})
      params[:symbol] ||= symbol
      params[:api_key] ||= conf[:api][:key]
      params[:timestamp] ||= Time.now.to_i * 1000

      sign = get_signature(params)
      params[:sign] = sign

      uri = URI(File.join(ENDPOINT, path))
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      res =
        http.start do |http|
          parse http.request_post(path, params.to_query)
        end

      if res['ret_code'] != 0
        raise ApiError.new(res)
      end

      res
    end

    def delete(path, params={})
      params[:symbol] ||= symbol
      params[:api_key] ||= conf[:api][:key]
      params[:timestamp] ||= Time.now.to_i * 1000

      sign = get_signature(params)
      params[:sign] = sign

      uri = URI(File.join(ENDPOINT, path))
      uri.query = params.to_query
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = parse(http.delete(uri.to_s))

      if res['ret_code'] != 0
        raise ApiError.new(res)
      end

      res
    end

    def get_signature(params)
      OpenSSL::HMAC.hexdigest('sha256', conf[:api][:secret], URI.encode_www_form(params.sort))
    end

    def parse(response)
      JSON.parse response.body
    rescue JSON::ParserError => e
      raise ResponseParseError.new(response.body)
    end

  end
end