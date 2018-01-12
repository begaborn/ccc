$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
autoload(:Bitflyer, 'my_bitflyer')

Bitflyer.currencies.each do |c|
  currency = Bitflyer.send(c)
  puts '-----------------------------------'
  puts "currency_code = #{currency.currency_code}"
  puts "price = #{currency.price}"
  puts "balance = #{currency.balance}"
  puts "jpy = #{currency.jpy}"
  puts ''
end


