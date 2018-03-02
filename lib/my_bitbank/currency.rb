module Bitbank
  # Currency Object.
  class Currency < Market::Currency
    class << self
      def client
        @client ||= Bitbankcc.new(
          conf[:api][:key],
          conf[:api][:secret]
        )
      end

      def conf
        {
          api: {
            key: ENV['BITBANK_API_KEY'], secret: ENV['BITBANK_API_SECRET'],
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
      ticker['last'].to_f
    end

    def volume
      ticker['vol'].to_f
    end

    def trades
      transactions.map do |trade|
        trade.tap do |t|
          t['date'] = (t.delete('executed_at') / 1000).to_i
          t['amount'] = t['amount'].to_f
          t['price'] = t['price'].to_i
          t['tid'] = t.delete('transaction_id')
        end
      end
    end

    def balance
      asset['onhand_amount'].to_f
    end

    def locked_balance
      asset['locked_amount'].to_f
    end

    def available_balance
      asset['free_amount'].to_f
    end

    def balance_pair
      jpy_asset['onhand_amount'].to_f
    end

    def locked_balance_pair
      jpy_asset['locked_amount'].to_f
    end

    def available_balance_pair
      jpy_asset['free_amount'].to_f
    end

    %w(maker taker).each do |type|
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

    def withdrawal_fee
      asset['withdrawal_fee']
    end

    def buy(amount, price: nil, limit: true)
      type = limit ? 'limit' : 'market'
      price = self.price if limit && price.nil?
      res = client.create_order(
        currency_pair,
        amount,
        price,
        'buy',
        type
      )
      JSON.parse(res)
    end

    def sell(amount, price: nil, limit: true)
      type = limit ? 'limit' : 'market'
      price = self.price if price.nil?
      res = client.create_order(
        currency_pair,
        amount,
        price,
        'sell',
        type
      )
      JSON.parse(res)
    end

    def cancel(tid)
      res = client.cancel_order(
        currency_pair,
        tid
      )
      JSON.parse(res)
    end

    def my_orders
      @my_orders ||=
        orders.map do |o|
          {
            'id'     => o['order_id'],
            'date'   => (o['ordered_at'] / 1000).to_i,
            'amount' => o['start_amount'].to_f,
            'price'  => o['price'].to_f,
            'side'   => o['side'],
          }
        end
    end

    def boards
    end

    def withdraw
    end

    private
    def ticker
      @ticker ||= JSON.parse(client.read_ticker(currency_pair).body)['data'] || []
    end

    def orders
      @orders ||= JSON.parse(client.read_active_orders(currency_pair))['data']['orders'] || []
    end

    def jpy_asset
      assets.find do |a|
        a['asset'] == pair
      end || {}
    end

    def asset
      assets.find do |a|
        a['asset'] == currency_code
      end || {}
    end

    def assets
      @assets ||= JSON.parse(client.read_balance)['data']['assets'] || []
    end

    def transactions
      @transactions ||= JSON.parse(client.read_transactions(currency_pair).body)['data']['transactions'] || []
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }