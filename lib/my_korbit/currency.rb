module Korbit
  # Currency Object.
  class Currency < Market::Currency
    class << self
      def client
        @client ||= Korbit::Client.new(
          client_id: conf[:api][:key],
          client_secret: conf[:api][:secret],
          username: conf[:api][:username],
          password: conf[:api][:password],
        )
      end

      def conf
        {
          api: {
            key: ENV['KORBIT_API_KEY'],
            secret: ENV['KORBIT_API_SECRET'],
            username: ENV['KORBIT_USERNAME'],
            password: ENV['KORBIT_PASSWORD'],
          },
        }
      end
    end

    def currency_code
      super.downcase
    end

    def default_pair
      'krw'
    end

    def price
      @price ||= (ticker['last'].to_i || -1)
    end

    def volume24h
      @volume ||= (detailed_ticker['volume'].to_f || -1)
    end

    def trades
      trades = []
      side_tmp = ''
      transactions.each_cons(2) do |before, t|
        if before['price'].to_i < t['price'].to_i
          side_tmp = 'buy'
        elsif before['price'].to_i > t['price'].to_i
          side_tmp = 'sell'
        end
        next if side_tmp.empty?
        t_data = {
          'date' => (t['timestamp'] / 1000).to_i,
          'tid' => t['tid'].to_i,
          'amount' => t['amount'].to_f,
          'price' => t['price'].to_i,
          'side' => side_tmp
        }
        trades << t_data
      end
      trades.sort_by do |t|
        t['date']
      end
    end

    def balance
      available_balance + locked_balance
    end

    def locked_balance
      balances[currency_code]['trade_in_use'].to_f
    end

    def available_balance
      balances[currency_code]['available'].to_f
    end

    def balance_pair
      available_balance_pair + locked_balance_pair
    end

    def locked_balance_pair
      balances['krw']['trade_in_use'].to_i + balances['krw']['withdrawal_in_use'].to_i
    end

    def available_balance_pair
      balances['krw']['available'].to_i
    end

    def maker_fee
      user_volume[currency_pair]['maker_fee'].to_f
    end

    def taker_fee
      user_volume[currency_pair]['taker_fee'].to_f
    end

    def withdrawal_fee
      constants['btcWithdrawalFee'].to_f
    end

    def buy(amount, price: nil, limit: true)
      type = limit ? 'limit' : 'market'
      p_price = if type == 'market'
        nil
      elsif price.nil?
        self.price.to_i
      else
        price.to_i.round_down(price_digit)
      end
      params = {
        currency_pair: currency_pair,
        price: p_price,
        coin_amount: amount.round_down(amount_digit),
        type: type
      }
      begin
        res = client.buy params
        order_res(res)
      rescue => e
        false
      end
    end

    def sell(amount, price: nil, limit: true)
      type = limit ? 'limit' : 'market'
      p_price = if type == 'market'
        nil
      elsif price.nil?
        self.price.to_i
      else
        price.to_i.round_down(price_digit)
      end

      params = {
        currency_pair: currency_pair,
        price: p_price,
        coin_amount: amount.round_down(amount_digit),
        type: type
      }
      begin
        res = client.sell params
        order_res(res)
      rescue => e
        false
      end
    end

    def cancel(tid)
      params = {
        currency_pair: currency_pair,
        tr_id: tid,
      }
      begin
        res = client.cancel params
        order_res(res.first)
      rescue => e
        false
      end
    end

    def my_orders
      @my_order ||=
        orders_open.map do |o|
          {
            'id'     => o['id'].to_i,
            'date'   => (o['timestamp'] / 1000).to_i,
            'amount' => o['total']['value'].to_f,
            'price'  => o['price']['value'].to_f,
            'side'   => (o['type'] == 'ask' ? 'sell' : 'buy'),
          }
        end
    end

    def find_order(id)
      order = order(id)
      return unless order
      order.tap do |o|
        o['id'] = o['id'].to_i
        o['side'] = (o['side'] == 'ask' ? 'sell' : 'buy')
        o['date'] = (o['created_at'] / 1000).to_i
        o['amount'] = o['order_amount']
        o.delete('created_at')
        o.delete('order_amount')
        o.delete('fee')
        o.delete('order_total')
        o.delete('filled_total')
      end
    end

    def boards
      orderbook
    end

    def withdraw
    end

    private
    def order_res(res)
      return false if res['status'] != 'success'
      res['orderId']
    end

    def orderbook
      begin
        @boards ||= client.orderbook(currency_pair)
      rescue => e
        {}
      end
    end

    def orders_open(limit = 10)
      params = {
        currency_pair: currency_pair,
        limit: limit,
      }
      begin
        @orders_open ||= client.orders_open params
      rescue => e
        puts e
        {}
      end
    end

    def order(id)
      params = {
        currency_pair: currency_pair,
        id: id,
        limit: 1,
      }
      begin
        client.orders(params).first
      rescue => e
        puts e
        false
      end
    end

    def balances
      @balances ||= client.balance
    end

    def user_volume
      begin
        @user_volume ||= client.user_volume(currency_pair)
      rescue => e
        {}
      end
    end

    def transactions
      begin
        @transactions ||= client.transactions(currency_pair)
      rescue => e
        {}
      end
    end

    def detailed_ticker
      begin
        @detailed_ticker ||= client.detailed_ticker(currency_pair)
      rescue => e
        {}
      end
    end

    def ticker
      begin
        @ticker ||= client.ticker(currency_pair)
      rescue => e
        {}
      end
    end

    def constants
      begin
        @constants ||= client.constants
      rescue => e
        {}
      end
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }