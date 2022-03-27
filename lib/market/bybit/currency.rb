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
      res = client.account
      res
    end

    def buy(amount, price: nil, limit: true, retry: 3)
      type = limit ? 'LIMIT' : 'MARKET'
      price = self.price if limit && price.nil?
      res = client.order('Buy', amount.round_down(amount_digit), type, price: price.to_f.round_down(price_digit))
    end

    def sell(amount, price: nil, limit: true, retry: 3)
      type = limit ? 'limit' : 'market'
      price = self.price if price.nil?
      client.order('Sell', amount.round_down(amount_digit), type, price: price.to_f.round_down(price_digit))
    end

    def cancel(id)
      client.cancel_order(id)
    end

    def my_orders
      client.open_orders
    end

    def find_order(id)
      client.get_order(id)
    end

    def amount_digit
      5
    end


    private

    def client
      @client ||= Client.new(symbol)
    end

    def symbol
      currency_pair.gsub('_', '').upcase
    end


  end

end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }