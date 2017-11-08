require 'bitflyer'
require 'transaction_log'
require 'my_bitflyer/currency'
require 'my_bitflyer/currency/btc'
require 'util'

# Action for Bitflyer
module MyBitflyer
  def btc
    MyBitflyer::Btc.new
  end
  module_function :btc

  # Action Class decide action for Selling, Buying, etc
  class Action
    attr_accessor :currency, :conf
    def initialize(currency, conf = YAML.load_file('config.yml'))
      self.currency = currency
      self.conf = conf[currency.currency_code] || {}
    end

    def transaction
      @transaction ||= TransactionLog.all
    end

    def rise?
      standard_price_for_selling < desire_price_for_selling
    end

    def decline?
      standard_price_for_buying > desire_price_for_buying
    end

    def buy
      data = {}
      data[:side] = 'BUY'
      data[:size] = buyable_size
      data[:price] = buying_price
      data[:fee] = fee(data[:size])
      data[:jpy] = data[:price] * (data[:size] + data[:fee])
#      currency.buy data
      TransactionLog.save data
    end

    def sell
      data = {}
      data[:side] = 'SELL'
      data[:size] = sellable_size
      data[:price] = selling_price
      data[:fee] = fee(data[:size])
      data[:jpy] = data[:price] * data[:size]
#     currency.sell data
      TransactionLog.save data
    end

    def sell?
      next_action_selling? && rise?
    end

    def buy?
      next_action_buying? && decline?
    end

    private

    def fee(size)
      size * currency.commission_rate
    end

    def buying_price
      (currency.price * down_rate(conf['more_price'].to_i)).to_i
    end

    def buyable_size
      currency.buyable_size.to_d.floor(3).to_f
    end

    def selling_price
      (currency.price * up_rate(conf['more_price'].to_i)).to_i
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
