require 'jwt'
require 'faraday'

module Upbit
  class Client
    # Mainnet
    ENDPOINT = 'https://api.upbit.com'.freeze

    attr_accessor :currency_pair

    def initialize(currency_pair)
      self.currency_pair = currency_pair
    end

    def account
      get('/v1/accounts')
    end

    def order(side, volume, price, ord_type)
      params = {
        market: self.currency_pair,
        side: side,
        volume: volume.to_s,
        price: price.to_s,
        ord_type: ord_type,
      }
      post('/v1/orders', params)
    end

    def delete_order(id)
      params = {
        uuid: id,
      }
      delete('/v1/order', params)
    end

    def get_orders(state = 'wait')
      params = {
        state: 'wait'
      }
      get('/v1/orders')
    end

    private

    def conf
      {
        api: {
          key: ENV['UPBIT_API_KEY'], secret: ENV['UPBIT_API_SECRET'],
        },
      }
    end

    def get_without_sign(path, params={})
    end

    def get(path, params={})
      uri = URI(File.join(ENDPOINT, path))
      req = Net::HTTP::Get.new(uri.request_uri)
      req.body = parmas.to_json if params.present?
      req['Authorization'] = get_authorize_token(params)
      req['Accept'] = 'application/json'
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      res =
        http.start do |http|
          http.request(req)
        end

      begin
        res.value
      rescue => e
        raise ApiError.new(res)
      end

      parse(res)
    end

    def post(path, params={})
      uri = URI(File.join(ENDPOINT, path))
      req = Net::HTTP::Post.new(uri.request_uri)
      req.body = params.to_json
      req['Authorization'] = get_authorize_token(params)
      req['Accept'] = 'application/json'
      req['Content-Type'] = 'application/json; charset=utf-8'

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true

      res =
        http.start do |http|
          http.request(req)
        end

      begin
        res.value
      rescue => e
        raise ApiError.new(res)
      end

      parse(res)
    end

    def delete(path, params={})
      uri = URI(File.join(ENDPOINT, path))
      req = Net::HTTP::Delete.new(uri.request_uri)
      req.body = params.to_json
      req['Authorization'] = get_authorize_token(params)
      req['Accept'] = 'application/json'
      req['Content-Type'] = 'application/json; charset=utf-8'

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = true
      res =
        http.start do |http|
          http.request(req)
        end
      begin
        res.value
      rescue => e
        raise ApiError.new(res.body)
      end

      parse(res)
    end

    def get_authorize_token(params = {})
      params.present? ? authorize_token_with_params(params) : authorize_token_without_params
    end

    def authorize_token_without_params
      payload = {
        access_key: conf[:api][:key],
        nonce: SecureRandom.uuid,
      }

      jwt_token = JWT.encode(payload, conf[:api][:secret], 'HS256')
      "Bearer #{jwt_token}"
    end


    def authorize_token_with_params(params)
      query_string = URI.encode_www_form(params)
      query_hash = Digest::SHA512.hexdigest(query_string)

      payload = {
          access_key: conf[:api][:key],
          nonce: SecureRandom.uuid,
          query_hash: query_hash,
          query_hash_alg: 'SHA512',
      }

      jwt_token = JWT.encode(payload, conf[:api][:secret], 'HS256')
      "Bearer #{jwt_token}"
    end

    def parse(response)
      JSON.parse response.body
    rescue JSON::ParserError => e
      raise ResponseParseError.new(response.body)
    end

  end
end