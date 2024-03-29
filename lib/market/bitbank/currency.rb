module Bitbank
  # Currency Object.
  class Currency < Market::Currency
    SIDE = {
      buy: 'buy',
      sell: 'sell',
    }.freeze

    class << self
      def client
        @client ||= Client.new(
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
      ticker['last'].to_f.round_down(price_digit)
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

    def my_orders
      ord = orders
      return false unless ord

      ord.map do |o|
        {
          'id'     => o['order_id'],
          'date'   => (o['ordered_at'] / 1000).to_i,
          'amount' => o['start_amount'].to_f.round_down(amount_digit),
          'price'  => o['price'].to_f.round_down(price_digit),
          'side'   => o['side'],
        }
      end
    end

    def find_order(id)
      order = get_order(id)
      return unless order
      order.tap do |o|
        o['id'] = o['order_id']
        o['currency_pair'] = o['pair']
        o['date'] = (o['ordered_at'] / 1000).to_i
        o['amount'] = o['start_amount']
        o['filled_amount'] = o['executed_amount']
        o['status'] = o['status'].downcase
        o['status'] = 'filled' if o['status'] == 'fully_filled'
        o['status'] = 'unfilled' if o['status'] == 'canceled_unfilled'
        o['status'] = 'partially_filled' if o['status'] == 'canceled_partially_filled'
        o.delete('order_id')
        o.delete('pair')
        o.delete('type')
        o.delete('start_amount')
        o.delete('remaining_amount')
        o.delete('executed_amount')
        o.delete('average_price')
        o.delete('ordered_at')
      end
    end

    def volume24h
      ticker['vol'].to_f
    end

    def trades
      trades = []
      side_tmp = ''
      transactions.sort_by do |t|
        t['executed_at']
      end.each_cons(2) do |before, t|
        if before['price'].to_f < t['price'].to_f
          side_tmp = 'buy'
        elsif before['price'].to_f > t['price'].to_f
          side_tmp = 'sell'
        end
        next if side_tmp.empty?
        t_data = {
          'date' => (t['executed_at'] / 1000).to_i,
          'tid' => t['transaction_id'],
          'amount' => t['amount'].to_f,
          'price' => t['price'].to_f.round_down(price_digit),
          'side' => side_tmp,
        }
        trades << t_data
      end
      trades
    end


    def depth
      @depth ||= JSON.parse(client.read_order_books(currency_pair))['data'] || []
    end

    def withdraw
    end

    def amount_digit
      4
    end

    def min_amount
      (0.1 ** amount_digit).round(amount_digit)
    end

    private

    def create_order(side, amount, price: nil, limit: true)
      type = limit ? 'limit' : 'market'
      price = self.price if price.nil?
      res = client.create_order(
        currency_pair,
        amount.round_down(amount_digit),
        price.to_f.round_down(price_digit),
        side.to_s,
        type
      )
      order_res(res)
    end

    def delete_order(tid)
      res = client.cancel_order(
        currency_pair,
        tid.to_i
      )
      order_res(res)
    end

    def order_res(res)
      res_json = JSON.parse(res)
      return false if res_json['success'] != 1
      res_json['data']['order_id']
    end

    def ticker
      @ticker ||= JSON.parse(client.read_ticker(currency_pair).body)['data'] || []
    end

    def get_order(id)
      res = JSON.parse(client.read_order(currency_pair, id))
      raise Market::ApiError.new("API:order ErrorCode:#{res['data']['code']}") if res['success'] != 1 || res['data'].nil? || res['data'].empty?
      res['data']
    end

    def orders
      res = JSON.parse(client.read_active_orders(currency_pair))
      raise Market::ApiError.new("API:active_orders ErrorCode:#{res['data']['code']}")  if res['success'] != 1 || res['data'].nil? || res['data'].empty?
      res['data']['orders']
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