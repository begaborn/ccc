$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

currency = Upbit.btc

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
puts "balance_pair = #{currency.balance_pair}"
puts "locked_balance_pair = #{currency.locked_balance_pair}"
puts "available_balance_pair = #{currency.available_balance_pair}"
amount = currency.buyable_amount(limit_cash: 10000, price: currency.price * 0.7)
puts "amount = #{amount}"
order_id = currency.buy amount, price: currency.price * 0.8
puts "order_id = #{order_id}"
currency.reload

puts "my_orders = #{currency.my_orders}"
puts "find_order = #{currency.find_order(order_id)}"
puts "balance = #{currency.balance}"
puts "locked_balance = #{currency.locked_balance}"
puts "available_balance = #{currency.available_balance}"

sleep 2
currency.all_cancel
currency.reload
puts "my_orders = #{currency.my_orders}"
puts ''

sleep 1