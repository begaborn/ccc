$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

# ------------------------------
# Usage
# ------------------------------
btc = Bybit.btc

# Get Current Price
price = btc.price

# Get your blance for BTC
blance = btc.balance
btc.buyable_amount(limit_cash: 10, price: price * 0.7)

# Place Buy order for BTC
order_id = btc.buy 0.001, price: price * 0.8

# Get your unfilled orders currently
my_orders = btc.my_orders

# Get a order for order_id
order = btc.find_order(order_id)

order_id = btc.cancel_order(order_id)

# Check all methods
kls = Bybit
kls.currencies.each do |c|
  currency = kls.send(c.to_sym)
  puts '-----------------------------------'
  puts "currency_code = #{currency.currency_code}"
  puts "default_pair = #{currency.default_pair}"
  puts "currency_pair = #{currency.currency_pair}"
  puts "min_amount = #{currency.min_amount}"
  puts "price_round_down = #{currency.price_round_down(12345.12345)}"
  puts "amount_round_down = #{currency.amount_round_down(123.12345678901)}"
  puts "price = #{currency.price}"

  amount = currency.buyable_amount(limit_cash: 100, price: currency.price * 0.7)
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

  currency.cancel_order(order_id)
  currency.reload
  puts "my_orders = #{currency.my_orders}"
  puts ''

  sleep 1
end
