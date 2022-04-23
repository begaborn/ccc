module Upbit
  # Currency Object.
  class Currency < Market::Currency

    def currency_code
      super.downcase
    end

    def default_pair
      'krw'
    end

    def price
      res = client.ticker
      target_res = res.find do |r|
        r['market'] == self.currency_pair
      end
      (target_res || {})['trade_price'].to_f
    end

    def balance
      asset['balance'].to_f
    end

    def available_balance
      asset['balance'].to_f - asset['locked'].to_f
    end

    def locked_balance
      asset['locked'].to_f
    end

    def balance_pair
      asset_pair['balance'].to_f
    end

    def available_balance_pair
      asset_pair['balance'].to_f - asset_pair['locked'].to_f
    end

    def locked_balance_pair
      asset_pair['locked'].to_f
    end

    def my_orders
      res = client.get_orders
      res.map do |r|
        {
          'id'     => r['uuid'],
          'date'   => Time.parse(r['created_at']).to_i,
          'amount' => r['volume'].to_f.round_down(amount_digit),
          'price'  => r['price'].to_f.round_down(price_digit),
          'side'   => convert_order_side(r['side']),
        }
      end
    end

    def find_order(id)
      r = client.get_order(id)
      res = {}
      res['id'] = r['uuid']
      res['currency_pair'] = r['market']
      res['date']   = Time.parse(r['created_at']).to_i,
      res['amount'] = r['volume'].to_f,
      res['price']  = r['price'].to_f,
      res['side']   = convert_order_side(r['side']),
      res['filled_amount'] = r['executed_volume']
      res['status'] = r['state'].downcase
      res['status'] = 'filled' if r['state'] == 'done'
      res['status'] = 'unfilled' if r['state'] == 'wait'
      res['status'] = 'partially_filled' if r['state'] == 'watch'

      res
    end

    def amount_digit
      5
    end

    def currency_pair
      "#{pair}-#{currency_code}".upcase
    end

    private

    ORDER_SIDE = {
      bid: 'buy',
      ask: 'sell',
    }

    def convert_order_side(side)
      ORDER_SIDE[side.to_sym]
    end

    def create_order(side, amount, price: nil, limit: true, retry: 3)
      type = limit ? 'limit' : 'market'
      side = convert_side(side)
      price = self.price if price.nil?
      res =client.order(side, amount.round_down(amount_digit), price.to_f.round_down(price_digit), type)
      res['uuid']
    end

    def delete_order(id)
      res = client.delete_order(id)
      res['uuid']
    end

    def client
      @client ||= Client.new(currency_pair)
    end

    def asset
      @asset ||= begin
        res = client.accounts
        res.find do |r|
          r['currency'] == currency_code.upcase
        end || {}
      end

    end

    def asset_pair
      @asset_pair ||= begin
        res = client.accounts
        res.find do |r|
          r['currency'] == pair.upcase
        end || {}
      end

    end

    def convert_side(side)
      case side
      when :buy
        'bid'
      when :sell
        'ask'
      else
        raise
      end
    end


  end

end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }