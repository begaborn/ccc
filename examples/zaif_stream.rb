$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
autoload(:Zaif, 'my_zaif')
btc = Zaif.btc
btc.stream
#btc.stream('stream.log')
#File.foreach('stream.log') do |line|
#  a = eval(line)
#  a[:trades]
#end