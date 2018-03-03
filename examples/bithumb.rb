$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
require 'my_bithumb'
autoload(:Bithumb, 'my_bithumb')

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end

#puts Korbit.currencies
eth = Bithumb.eth
puts eth.ticker
puts eth.orderbook
