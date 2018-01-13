require 'bitflyer'
require 'my_bitflyer/currency'

# Module for Bitflyer
module Bitflyer
  def currencies
    Currency.subclasses.map do |currency|
      currency_sym = currency.code.downcase.to_sym
    end
  end
  module_function :currencies

  Currency.subclasses.each do |currency|
    currency_sym = currency.code.downcase.to_sym
    define_method(currency_sym) do
      currency.new
    end
    module_function currency_sym
  end

  module Realtime
    class Client
      def initialize(logger = nil)
        logger = logger || pubnub_logger
        @pubnub = Pubnub.new(
          subscribe_key: Realtime::PUBNUB_SUBSCRIBE_KEY,
          logger: logger
        )

        @callback = Pubnub::SubscribeCallback.new(
            message: ->(envelope) {
              channel_name = envelope.result[:data][:subscribed_channel].gsub('lightning_', '').downcase.to_sym
              message = envelope.result[:data][:message]
              send(channel_name).call(message) if send(channel_name)
            },
            presence: ->(envelope) {},
            status: ->(envelope) {}
        )

        @pubnub.add_listener(callback: @callback)
        @pubnub.subscribe(channels: Realtime::CHANNEL_NAMES)
      end

      private

      def pubnub_logger
        logger = logger || Logger.new('pubnub_error.log')
        logger.level = Logger::ERROR
        logger
      end
    end
  end
end
