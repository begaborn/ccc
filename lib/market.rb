require 'util'
require 'transaction_log'
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

    def initialize(pair = 'jpy', market_conf = load_default_yml)
      @pair = pair
      @market_conf = market_conf[market_name] || {}
    end

    def reload
      instance_variables.each do |var|
        remove_instance_variable(var)
      end
      self
    end

    def namespace
      self.class.namespace
    end
    alias_method :market_name, :namespace

    def currency_code
      self.class.code
    end

    def currency_pair
      "#{currency_code}_#{pair}"
    end

    def client
      self.class.client
    end

    def conf
      self.class.conf.merge(market_conf)
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

    def jpy
      balance * price
    end

    private

    def load_default_yml
      return {} unless File.exist?(Ccc.configuration.yml_filename.to_s)
      YAML.load_file(Ccc.configuration.yml_filename.to_s)
    end
  end
end
