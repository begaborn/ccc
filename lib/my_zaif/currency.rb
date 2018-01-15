module Zaif
  # Currency Object.
  class Currency < Market::Currency
    class << self
      def client
        @client ||= Zaif::API.new(
          api_key: conf[:api][:key],
          api_secret: conf[:api][:secret],
        )
      end

      def conf
        @conf ||= {
          api: {
            key: ENV['ZAIF_API_KEY'], secret: ENV['ZAIF_API_SECRET'],
          },
        }
      end
    end

    def currency_code
      super.downcase
    end

    def realtime_board(output_filename = nil)
      client.stream(currency_code, "jpy", output_filename.to_s)
    end

    def balance
      balance = info_without_transactions['deposit'][currency_code.upcase] || 0
      if balance.nil?
        puts "Warning: Currency Code #{currency_code} is Not Supported for #{market_name}"
      end
      balance || 0.0
    end

    def funds
      balance = info_without_transactions['funds'][currency_code.upcase] || 0
      if balance.nil?
        puts "Warning: Currency Code #{currency_code} is Not Supported for #{market_name}"
      end
      balance || 0.0
    end

    def jpy
      balance * price
    end

    %w(withdrawal maker taker).each do |type|
      define_method("#{type}_fee") do
        fee = 0
        begin
          fee = conf[currency_code]['fee'][type]
        rescue => e
          puts "Warning: Not Configured #{type} Fee for #{currency_code}"
        end
        fee
      end
    end

    # +: Buyers are more than sellers(may be increased the price)
    # -: Sellers are more than buyers(may be decreased the price)
    def ask_bid_amount(limit = 0)
      bid_amount(limit) - ask_amount(limit)
    end

    def ask_amount(limit = 0)
      board_amount('asks', limit)
    end

    def bid_amount(limit = 0)
      board_amount('bids', limit)
    end

    def board_amount(type, limit = 0)
      return -1 if depth.empty?
      l_board =
        if limit > 0
          depth[type].slice(0..(limit - 1))
        else
          depth[type]
        end
      l_board.reduce(0) do |sum, (p, amount)|
        sum += amount
      end
    end
    def ask_bid_avg_price(limit = 0)
      price + (ask_bid_volume(limit) / (ask_amount(limit) + bid_amount(limit)))
    end

    def ask_bid_volume(limit = 0)
      ask_volume(limit) + bid_volume(limit)
    end

    def ask_volume(limit = 0)
      board_volume('asks', limit)
    end

    def bid_volume(limit = 0)
      board_volume('bids', limit)
    end

    def board_volume(type, limit = 0)
      return -1 if depth.empty?
      l_board =
        if limit > 0
          depth[type].slice(0..(limit - 1))
        else
          depth[type]
        end
      l_board.reduce(0) do |sum, (p, amount)|
        sum += ((p - price) * amount)
      end
    end

    def volume
      ticker['volume']
    end

    def vwap
      ticker['vwap']
    end

    def price
      @price ||= ticker['last']
    end

    def withdraw(address, amount, option = {})
      client.withdraw(currency_code, address, amount, option)
    end

    def info
      @info ||= client.get_info
    end

    def info_without_transactions
      @info_without_tr ||= client.get_info_without_transactions
    end

    def last_price
      begin
        @last_price ||= client.get_last_price(currency_code)
      rescue => e
        -1
      end
    end

    def order_books
      @trades ||= client.get_trades(currency_code)
    end

    def trades
      begin
        @trades ||= client.get_trades(currency_code)
      rescue => e
        {}
      end
    end

    def ticker
      begin
        @ticker ||= client.get_ticker(currency_code)
      rescue => e
        {}
      end
    end

    def depth
      begin
        @depth ||= client.get_depth(currency_code)
      rescue => e
        {}
      end
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }