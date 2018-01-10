require 'util'
require 'transaction_log'
module Market
  class Action
    attr_accessor :currency, :conf
    def initialize(currency, conf = YAML.load_file('config.yml'))
      self.currency = currency
      self.conf = (conf[self.namespace] && conf[self.namespace][currency.currency_code.downcase]) || {}
    end

    def transaction
      @transaction ||= TransactionLog.all
    end

    def namespace
      self.class.name.split('::')[0].downcase
    end
    alias_method :market_name, :namespace
  end

  class Currency
    def reload
      instance_variables.each do |var|
        remove_instance_variable(var)
      end
      self
    end

    def namespace
      self.class.name.split('::')[0].downcase
    end
    alias_method :market_name, :namespace

    def currency_code
      self.class.to_s.split('::')[1]
    end

    def currency_pair
      raise "Not Supported"
    end

    def price
      raise "Not Supported"
    end

    def realtime_board
      raise "Not Supported"
    end
  end
end
