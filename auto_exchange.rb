$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/lib')
require 'my_bitflyer'
require 'pry-byebug'

# Auto-Exchange Program for Cryptocurrency.

# Action object for Bitcoin.
action = MyBitflyer::Action.btc

# If the last action is 'Sell', the program will try to buy coin.
# But when the 'sell' conditions are not satisfied, no action.
if action.sell?
  p "Sell #{btc.currency_code}"
  action.sell

# If the last action is 'buy', the program will try to sell coin.
# But when the 'buy' conditions are not satisfied, no action.
elsif action.buy?
  p "Buy #{btc.currency_code}"
  action.buy

# Because the conditions are not satisfied, no action.
else
  p 'No Action'
end
