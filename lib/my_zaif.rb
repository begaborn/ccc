require 'zaif'
require 'my_zaif/currency'
require 'websocket-client-simple'

# Module for Zaif
module Zaif
  # Currency code with symbolic
  # return [:btc, :bch, eth, ...]
  def currencies
    Currency.subclasses.map do |currency|
      currency_sym = currency.code.downcase.to_sym
    end
  end

  module_function :currencies

  # Define method that get the currency object
  # Usage: btc = Zaif.btc
  Currency.subclasses.each do |currency|
    currency_sym = currency.code.downcase.to_sym
    define_method(currency_sym) do
      currency.new
    end
    module_function currency_sym
  end

  class API
    # Get user infomation without transactions.
    def get_info_without_transactions
      json = post_ssl(@zaif_trade_url, "get_info2", {})
      return json
    end

    # Order book stream by Websocket
    def stream(currency_code, counter_currency_code = "jpy", output_filename = nil)
      f = if output_filename.nil?
            STDOUT
          else
            File.open(output_filename, 'a')
          end
      ws = WebSocket::Client::Simple.connect "wss://ws.zaif.jp:8888/stream?currency_pair=#{currency_code}_#{counter_currency_code}"
      ws.on :message do |msg|
        f.puts msg.data + "\n"
      end

      ws.on :close do |e|
        f.close unless output_filename.nil?
      end

      loop do
      end
    end
  end
end
