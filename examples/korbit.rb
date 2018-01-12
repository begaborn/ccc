$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
autoload(:Korbit, 'my_korbit')

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end

puts Korbit.currencies
eth = Korbit.eth
puts eth.price
