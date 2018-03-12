require 'ruby_bitbankcc'
require 'my_bitbank/currency'

# Module for Bitbank
module Bitbank
  # Currency code with symbolic
  # return [:btc, :bch, eth, ...]
  def currencies
    Currency.subclasses.map do |currency|
      currency_sym = currency.code.downcase.to_sym
    end
  end

  module_function :currencies

  # Define method that get the currency object
  # Usage: btc = Bitbank.btc
  Currency.subclasses.each do |currency|
    currency_sym = currency.code.downcase.to_sym
    define_method(currency_sym) do
      currency.new
    end
    module_function currency_sym
  end
end

class Bitbankcc
  def read_order(pair, order_id)
    path = "/v1/user/spot/order"
    nonce = Time.now.to_i.to_s
    params = {
      pair: pair,
      order_id: order_id
    }.compact
    request_for_get(path, nonce, params)
  end
end