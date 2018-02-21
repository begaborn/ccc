$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
autoload(:Korbit, 'my_korbit')

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end

#puts Korbit.currencies
eth = Korbit.eth
puts eth.krw
puts eth.trades
eth.reload
puts eth.withdrawal_fee
puts eth.maker_fee
puts eth.taker_fee
puts eth.price
puts eth.volume
puts eth.balance
puts eth.funds

puts Korbit::Currency.krw_balance
#puts eth.buy 100000, 0.1
#eth.sell 2000, 100.0
puts eth.reload.unfilled_order
