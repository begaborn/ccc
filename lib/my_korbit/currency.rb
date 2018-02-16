module Korbit
  # Currency Object.
  class Currency < Market::Currency
    def method_missing(action, *args)
      self.class.__send__ action, *args
    end

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
        @conf ||= {
          api: {
            key: ENV['KORBIT_API_KEY'],
            secret: ENV['KORBIT_API_SECRET'],
            username: ENV['KORBIT_USERNAME'],
            password: ENV['KORBIT_PASSWORD'],
          },
        }
      end

      def krw_balance
        client.balance['krw']['available'].to_i
      end

      def krw_funds
        client.balance['krw']['trade_in_use'].to_i
      end
    end

    def client
      self.class.client
    end

    def conf
      self.class.conf
    end

    def krw_balance
      @krw_balance ||= self.class.krw_balance
    end

    def krw_funds
      @krw_funds ||= self.class.krw_funds
    end

    def currency_code
      super.downcase
    end

    def pair
      'krw'
    end

    def currency_pair
      "#{currency_code}_#{pair}"
    end

    def balance
      @balacne ||= client.balance[currency_code]['available'].to_i
    end

    def funds
      @funds ||= client.balance[currency_code]['trade_in_use'].to_i
    end

    def krw
      balance * price
    end

    def price
      @price ||= (ticker['last'].to_i || -1)
    end

    def volume
      @volume ||= (detailed_ticker['volume'].to_i || -1)
    end

    def trades
      @trades ||= transactions.map do |trade|
        trade.tap do |t|
          t['date'] = (t.delete('timestamp') / 1000).to_i
          t['amount'] = t['amount'].to_f
          t['price'] = t['price'].to_i
        end
      end
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

    def unfilled_order
      @unfilled_order ||=
        orders_open.map do |o|
          {
            id: o['id'],
            date: (o['timestamp'] / 1000).to_i,
            amount: o['total']['value'].to_i,
            price: o['price']['value'].to_i,
            type: o['type'],
          }
        end
    end

    def orderbook
      begin
        @orderbook ||= client.orderbook(currency_pair)
      rescue => e
        {}
      end
    end

    def orders(id)
      begin
        params = {
          currency_pair: currency_pair,
          id: id,
        }
        @orders ||= client.orders params
      rescue => e
        puts e
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

    def buy(price, amount)
      params = {
        currency_pair: currency_pair,
        price: price,
        coin_amount: amount
      }

      client.buy params
    end

    def sell(price, amount)
      params = {
        currency_pair: currency_pair,
        price: price,
        coin_amount: amount
      }
      client.sell params
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