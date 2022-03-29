module Bybit
  # Currency Object.
  class Currency < Market::Currency

    def currency_code
      super.downcase
    end

    def default_pair
      'usdc'
    end

    def price
      res = client.price
      res['result']['price'].to_f
    end

    def balance
      asset['total'].to_f
    end

    def available_balance
      asset['free'].to_f
    end

    def locked_balance
      asset['locked'].to_f
    end

    def balance_pair
      asset_pair['total'].to_f
    end

    def available_balance_pair
      asset_pair['free'].to_f
    end

    def locked_balance_pair
      asset_pair['locked'].to_f
    end

    def my_orders
      res = client.open_orders
      res['result'].select do |r|
        r['status'] == 'NEW'
      end.map do |r|
        {
          'id'     => r['orderLinkId'],
          'date'   => r['updateTime'].to_i,
          'amount' => r['origQty'],
          'price'  => r['price'],
          'side'   => r['side'],
        }
      end
    end

    def find_order(id)
      res = client.get_order(id)
      r = res['result']
      {
        'id' => r['orderLinkId'],
        'currency_pair' => r['symbol'],
        'date' => r['updateTime'].to_i,
        'amount' => r['origQty'],
        'filled_amount' => r['executedQty'],
        'status' => convert_status(r['status'])
      }
    end

    def amount_digit
      5
    end


    private

    def create_order(side, amount, price: nil, limit: true)
      type = limit ? 'LIMIT' : 'MARKET'
      side = convert_side(side)
      price = self.price if price.nil?
      res = client.create_order(side, amount.round_down(amount_digit), type, price: price.to_f.round_down(price_digit))
      res['result']['orderLinkId']
    end

    def delete_order(id)
      res = client.delete_order(id)
      res['result']['orderLinkId']
    end

    def client
      @client ||= Client.new(symbol)
    end

    def symbol
      currency_pair.gsub('_', '').upcase
    end

    def asset
      @asset ||= begin
        res = client.account
        res['result']['balances'].find do |r|
          r['coin'] == currency_code.upcase
        end || {}
      end
    end

    def asset_pair
      @asset_pair ||= begin
        res = client.account
        res['result']['balances'].find do |r|
          r['coin'] == pair.upcase
        end || {}
      end
    end

    def convert_status(status)
      case status
      when 'FILLED'
        'filled'
      when 'PARTIALLY_FILLED'
        'partially_filled'
      else
        'unfilled'
      end
    end

    def convert_side(side)
      case side
      when :buy
        'Buy'
      when :sell
        'Sell'
      else
        raise
      end
    end

  end

end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }