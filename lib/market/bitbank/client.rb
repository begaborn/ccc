require 'ruby_bitbankcc'

module Bitbank
  class Client < Bitbankcc
    def read_order(pair, order_id)
      path = "/v1/user/spot/order"
      nonce = Time.now.to_i.to_s
      params = {
        pair: pair,
        order_id: order_id
      }.compact
      request_for_get(path, nonce, params)
    end

    def request_for_get(path, _, query = {})
      nonce = self.nonce
      uri = URI.parse @@base_url + path
      signature = get_get_signature(path, @secret, nonce, query)

      headers = {
        "Content-Type" => "application/json",
        "ACCESS-KEY" => @key,
        "ACCESS-NONCE" => nonce,
        "ACCESS-SIGNATURE" => signature
      }

      uri.query = query.to_query
      request = Net::HTTP::Get.new(uri.request_uri, initheader = headers)
      http_request(uri, request)
    end

    def request_for_post(path, nonce, body)
      nonce = self.nonce
      uri = URI.parse @@base_url + path
      signature = get_post_signature(@secret, nonce, body)

      headers = {
        "Content-Type" => "application/json",
        "ACCESS-KEY" => @key,
        "ACCESS-NONCE" => nonce,
        "ACCESS-SIGNATURE" => signature,
        "ACCEPT" => "application/json"
      }

      request = Net::HTTP::Post.new(uri.request_uri, initheader = headers)
      request.body = body

      http_request(uri, request)
    end

    def nonce
      now = Time.now
      (now.to_f * 100).to_i.to_s
    end

  end
end