$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
autoload(:Coincheck, 'my_coincheck')

Coincheck.currencies.each do |c|
  currency = Coincheck.send(c)
  puts "currency_code = #{currency.currency_code}"
  puts "currency_pair = #{currency.currency_pair}"
  puts "price = #{currency.price}"
  puts ''
end
