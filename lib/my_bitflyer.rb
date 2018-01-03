require 'bitflyer'
require 'my_bitflyer/currency'

# Module for Bitflyer
module Bitflyer
  CURRENCIES = [:btc]

  CURRENCIES.each do |currency|
    define_method(currency) do
      "#{self.to_s}::#{currency.to_s.classify}".constantize.new
    end
    module_function currency
  end

  # Action Class decide action for Selling, Buying, etc
  class Action < Market::Action
    class << self
      CURRENCIES.each do |currency|
        require "my_bitflyer/currency/#{currency}"
        define_method(currency) do
          new(Bitflyer.send(currency))
        end
      end
    end

    def currency_code
      super.upcase
    end

    def rise?
      standard_price_for_selling < desire_price_for_selling
    end

    def decline?
      standard_price_for_buying > desire_price_for_buying
    end

    def buy
      data = {}
      data[:market] = 'Bitflyer'
      data[:date] = Time.now
      data[:side] = 'BUY'
      data[:size] = buyable_size
      data[:price] = buying_price
      data[:fee] = fee(data[:size])
      data[:jpy] = data[:price] * (data[:size] + data[:fee])
      currency.buy(data[:size], data[:price])
      TransactionLog.save data
    end

    def sell
      data = {}
      data[:market] = 'Bitflyer'
      data[:date] = Time.now
      data[:side] = 'SELL'
      data[:size] = sellable_size
      data[:price] = selling_price
      data[:fee] = fee(data[:size])
      data[:jpy] = data[:price] * data[:size]
      currency.sell(data[:size], data[:price])
      TransactionLog.save data
    end

    def sell?
      next_action_selling? && rise? && !currency.in_active?
    end

    def buy?
      (buyable_size > 0 || next_action_buying?) && decline? && !currency.in_active?
    end

    private

    def fee(size)
      size * currency.commission_rate
    end

    def buying_price
      (currency.price * down_rate(conf['more_price'].to_f)).to_i
    end

    def buyable_size
      currency.buyable_size.to_d.floor(3).to_f
    end

    def selling_price
      (currency.price * up_rate(conf['more_price'].to_f)).to_i
    end

    def sellable_size
      currency.sellable_size.to_d.floor(3).to_f
    end

    def next_action_selling?
      if transaction.empty?
        conf['init_action'] &&
          conf['init_action'] == 'SELL'
      else
        # If last action is 'buying', next action is selling
        currency.last_action_buying?
      end
    end

    def next_action_buying?
      !next_action_selling?
    end

    def desire_price_for_selling
      currency.price_for_selling * down_rate(conf['yield'].to_i)
    end

    def standard_price_for_selling
      if conf['desire_price'].present?
        conf['desire_price'].to_i
      elsif currency.latest_bought_max_price.zero?
        conf['init_price'].to_i
      else
        currency.latest_bought_max_price
      end
    end

    def desire_price_for_buying
      currency.price_for_buying * up_rate(conf['yield'].to_i)
    end

    def standard_price_for_buying
      if conf['desire_price'].present?
        conf['desire_price'].to_i
      elsif currency.latest_sold_price.zero?
        conf['init_price'].to_i
      else
        currency.latest_sold_price
      end
    end
  end
end
