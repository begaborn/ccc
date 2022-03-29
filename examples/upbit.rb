$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

btc = Upbit.btc
p btc.price
p btc.balance
#p btc.available_balance
#p btc.locked_balance
#
#order_id = btc.buy(0.001, price: 10000)
#p btc.my_orders
#p btc.find_order(order_id)
#binding.pry
#btc.cancel(order_id)
