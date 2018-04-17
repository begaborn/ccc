module Market

  class NotConfigured < StandardError; end

  class Currency
    attr_accessor :pair
    attr_accessor :market_conf

    class << self
      def namespace
        self.name.split('::')[0].downcase
      end
      alias_method :market_name, :namespace

      def code
        self.to_s.split('::')[1]
      end
    end

    def initialize(pair = nil, market_conf = load_default_yml)
      @pair = pair || default_pair
      @market_conf = market_conf[market_name] || {}
    end

    def reload
      instance_variables.each do |var|
        next if [:@pair, :@market_conf].include?(var)
        remove_instance_variable(var)
      end
      self
    end

    def namespace
      self.class.namespace
    end
    alias_method :market_name, :namespace

    def code
      self.class.code
    end
    alias_method :currency_code, :code

    def currency_pair
      "#{currency_code}_#{pair}"
    end

    def client
      self.class.client
    end

    def conf
      @conf ||= self.class.conf.merge(@market_conf)
    end

    def to_pair
      (balance * price).round(3)
    end

    def volume
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def vwap
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def price
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def realtime_board
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def balance
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def default_pair
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def buy(amount, price: nil, limit: true)
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def sell(amount, price: nil, limit: true)
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def cancel(tid)
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def trades
      raise NotImplementedError.new("Not Supported: #{self.class}##{__method__}")
    end

    def vpin
      bucket_num = 2
      bucket_size = (latest_volume / bucket_num.to_f).round_down(amount_digit)
      bucket_index = 0
      bucket = []
      trades.each do |data|
        bucket[bucket_index] ||= {}
        bucket[bucket_index]['sum'] ||= 0
        bucket[bucket_index][data['side']] ||= 0

        available_size = bucket_size - bucket[bucket_index]['sum']

        if available_size < data['amount']
          bucket[bucket_index]['sum'] += available_size
          bucket[bucket_index][data['side']] += available_size

          bucket_index += 1
          break if bucket_index == bucket_num

          bucket[bucket_index] ||= {}
          bucket[bucket_index]['sum'] ||= 0
          bucket[bucket_index][data['side']] ||= 0
          bucket[bucket_index]['sum'] += (data['amount'] - available_size)
          bucket[bucket_index][data['side']] += (data['amount'] - available_size)
        else
          bucket[bucket_index]['sum'] += data['amount']
          bucket[bucket_index][data['side']] += data['amount']
        end
      end

      sum_b = bucket.reduce(0) do |sum, b|
        sum += (b['sell'].to_f - b['buy'].to_f).abs
      end
      (sum_b / (bucket_num * bucket_size).to_f).round(3)
    end

    def latest_volume
      trades.sum do |t|
        t['amount']
      end
    end

    def latest_buy_volume
      latest_volume_by('buy')
    end

    def latest_sell_volume
      latest_volume_by('sell')
    end

    def latest_buy_rate
      return 0 if latest_volume.zero?
      ((latest_buy_volume / latest_volume).to_f *  100).round(1)
    end

    def latest_sell_rate
      return 0 if latest_volume.zero?
      ((latest_sell_volume / latest_volume).to_f *  100).round(1)
    end

    def latest_volume_by(side)
      trades.select do |t|
        t['side'] == side
      end.sum do |t|
        t['amount']
      end
    end

    def all_cancel
      my_orders.each do |order|
        stickily_cancel order['id']
      end
    end

    def buyable_amount(limit_cash: nil, price: nil)
      cash = [(limit_cash.nil? ? available_balance_pair : limit_cash.to_i), available_balance_pair].min
      orderable_amount(balance: cash, price: price).round_down(amount_digit)
    end

    def sellable_amount(limit_coin: nil)
      [(limit_coin.nil? ? available_balance : limit_coin.to_f), available_balance].min.round_down(amount_digit)
    end

    def orderable_amount(balance: nil, price: nil)
      price = price || self.price
      available_balance_pair = balance || self.available_balance_pair
      (available_balance_pair.to_f / price.to_f).round_down(amount_digit)
    end

    def price_digit
      0
    end

    def amount_digit
      0
    end

    def stickily_buy(amount, price: nil, limit: true, retry_count: 10)
      res = false
      1.step do |index|
        res = buy amount, price: price, limit: limit
        break if index >= retry_count || res
        sleep 1
      end
      res
    end

    def stickily_sell(amount, price: nil, limit: true, retry_count: 10)
      res = false
      1.step do |index|
        res = sell amount, price: price, limit: limit
        break if index >= retry_count || res
        sleep 1
      end
      res
    end

    def stickily_cancel(tid, retry_count: 10)
      res = false
      1.step do |index|
        res = cancel tid
        break if index >= retry_count || res
        sleep 1
      end
      res
    end

    def price_round_down(price)
      price.round_down(price_digit)
    end

    def amount_round_down(amount)
      amount.round_down(amount_digit)
    end

    private

    def load_default_yml
      return {} unless File.exist?(Ccc.configuration.yml_filename.to_s)
      YAML.load_file(Ccc.configuration.yml_filename.to_s)
    end
  end
end

class Float
  def round_down(digit)
    f = self.to_s.to_d.floor(digit).to_f
    digit > 0 ? f : f.to_i
  end
end

class Fixnum
  def round_down(digit)
    self.to_s.to_d.floor(digit).to_i
  end
end
