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

    end

    def find_order(id)
    end

    def amount_digit
      5
    end

    def currency_pair
      "#{pair}-#{currency_code}".upcase
    end

    private

    def create_order(side, amount, price: nil, limit: true, retry: 3)
      type = limit ? 'limit' : 'market'
      side = convert_side(side)
      price = self.price if price.nil?
      res =client.order(side, amount.round_down(amount_digit), price.to_f.round_down(price_digit), type)
      res["uuid"]
    end

    def delete_order(id)
      client.delete_order(id)
    end


    def client
      @client ||= Client.new(currency_pair)
    end

    def asset
      @target_asset ||= begin
        res = client.accounts
        res.find do |r|
          r['currency'] == currency_code.upcase
        end || {}
      end

    end

    def asset_pair
      @target_asset ||= begin
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
        'sell'
      else
        raise
      end
    end


  end

end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }