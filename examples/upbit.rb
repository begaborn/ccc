$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

currency = Upbit.xrp
puts '-----------------------------------'
puts "currency_code = #{currency.currency_code}"
puts "default_pair = #{currency.default_pair}"
puts "currency_pair = #{currency.currency_pair}"
puts "min_amount = #{currency.min_amount}"
puts "price_round_down = #{currency.price_round_down(12345.12345)}"
puts "amount_round_down = #{currency.amount_round_down(123.12345678901)}"
puts "price = #{currency.price}"
puts "balance = #{currency.balance}"
puts "available_balance = #{currency.available_balance}"
puts "locked_balance = #{currency.locked_balance}"
amount = currency.buyable_amount(limit_cash: 10000, price: currency.price * 0.7)
puts "amount = #{amount}"


#p btc.available_balance
#p btc.locked_balance
#
#order_id = btc.buy(0.001, price: 10000)
#p btc.my_orders
#p btc.find_order(order_id)
#binding.pry
#btc.cancel(order_id)
