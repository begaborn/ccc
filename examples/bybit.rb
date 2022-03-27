$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
btc = Upbit.btc

#order_id = btc.buy(0.01, price: 1000000)
p btc.my_orders
binding.pry
btc.cancel(order_id)

#btc.balance
#p btc.balance

#p btc.price
#p btc.balance
#btc.buy(0.0003, price: 40000.01)
#p btc.my_orders
#btc.cancel('1648324732534756')