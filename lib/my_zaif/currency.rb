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
        {
          api: {
            key: ENV['ZAIF_API_KEY'], secret: ENV['ZAIF_API_SECRET'],
          },
        }
      end
    end

    def currency_code
      super.downcase
    end

    def default_pair
      'jpy'
    end

    def price
      ticker['last'].to_i
    end

    def volume24h
      ticker['volume'].to_f
    end

    def trades
      get_trades.map do |trade|
        trade.tap do |t|
          t['side'] = (t.delete('trade_type') == 'ask' ? 'buy' : 'sell')
        end
      end
    end

    def balance
      info_without_transactions['deposit'][currency_code].to_f
    end

    def locked_balance
      balance_pair - available_balance_pair
    end

    def available_balance
      info_without_transactions['funds'][currency_code].to_f
    end

    def balance_pair
      info_without_transactions['deposit'][pair].to_f
    end

    def locked_balance_pair
      balance_pair - available_balance_pair
    end

    def available_balance_pair
      info_without_transactions['funds'][pair].to_f
    end

    %w(withdrawal maker taker).each do |type|
      define_method("#{type}_fee") do
        fee = 0
        begin
          fee = conf[currency_code.downcase]['fee'][type]
        rescue => e
          puts "Warning: Not Configured #{type} Fee for #{currency_code}"
        end
        fee
      end
    end

    def buy(amount, price: nil, limit: true)
      price = self.price if limit && price.nil?
      client.bid currency_code, price.round_down(price_digit), amount.round_down(amount_digit), limit, pair
      order_res(res)
    end

    def sell(amount, price: nil, limit: true)
      price = self.price if limit && price.nil?
      res = client.sell currency_code, price.round_down(price_digit), amount.round_down(amount_digit), limit, pair
      order_res(res)
    end

    def cancel(tid)
      client.cancel(tid)
      order_res(res)
    end

    def my_orders
      active_orders.map do |k,v|
        {
          'id'     => k,
          'date'   => v['timestamp'],
          'amount' => v['amount'].to_f,
          'price'  => v['price'].to_f,
          'side'   => (v['action'] == 'ask' ? 'sell' : 'buy'),
        }
      end
    end

    def board
      depth
    end

    def withdraw(address, amount, option = {})
      client.withdraw(currency_code, address, amount, option)
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

    def latest_volume

    end

    def vwap24h
      ticker['vwap'].to_f
    end

    def stream(output = nil)
      client.stream(currency_code, "jpy", output)
    end

    private
    def order_res(res)
      return false if res['success'] != 1
      res['return']['order_id']
    end

    def info
      @info ||= client.get_info
    end

    def info_without_transactions
      @info_without_tr ||= client.get_info_without_transactions
    end

    def last_price
      begin
        @last_price ||= client.get_last_price(currency_code.downcase)
      rescue => e
        -1
      end
    end

    def get_trades
      begin
        @trades ||= client.get_trades(currency_code.downcase)
      rescue => e
        {}
      end
    end

    def ticker
      begin
        @ticker ||= client.get_ticker(currency_code.downcase)
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

    def active_orders
      begin
        @active_orders ||= client.get_active_orders(currency_pair: currency_pair)
      rescue => e
        {}
      end
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }