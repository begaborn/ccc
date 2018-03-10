require 'util'
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

    def to_pair
      (balance * price).round(3)
    end

    def conf
      self.class.conf.merge(@market_conf)
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

    def orderable_amount
      (available_balance_pair.to_f / price.to_f).round_down(amount_digit)
    end

    def price_digit
      0
    end

    def amount_digit
      0
    end

    private

    def load_default_yml
      return {} unless File.exist?(Ccc.configuration.yml_filename.to_s)
      YAML.load_file(Ccc.configuration.yml_filename.to_s)
    end
  end
end
