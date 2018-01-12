$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
autoload(:Zaif, 'my_zaif')
btc = Zaif.btc
btc.realtime_board('/tmp/realtime_test.log')