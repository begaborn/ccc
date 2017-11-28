$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/lib')
require 'my_bitflyer'
require 'pry-byebug'

action = MyBitflyer::Action.btc
btc = action.currency

while true
  btc.r_executions(log_file('executions'))
  sleep 1
end