require 'bitflyer'
require 'pry-byebug'
require 'my_bitflyer/currency'
require 'my_bitflyer/currency/btc'

module MyBitflyer
  def btc
    MyBitflyer::Btc.new
  end
  module_function :btc
end
