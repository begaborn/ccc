$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end


xrp = Bitbank.xrp
puts xrp.price

eth = Bitbank.eth
puts eth.price
