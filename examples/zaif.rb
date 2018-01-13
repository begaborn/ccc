$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end

btc = Zaif.btc
puts btc.price

Zaif.currencies.each do |c|
  currency = Zaif.send(c)
  puts '-----------------------------------'
  puts "currency_code = #{currency.currency_code}"
  puts "price = #{currency.price}"
  puts "balance = #{currency.balance}"
  puts "funds = #{currency.funds}"
  puts "jpy = #{currency.jpy}"
  puts "withdrawal fee = #{currency.withdrawal_fee}"
  puts "maker fee = #{currency.maker_fee}"
  puts "taker fee = #{currency.taker_fee}"
  puts "vwap = #{currency.vwap}"
  puts "last_price = #{currency.last_price}"
  puts "trades = #{currency.trades}"
  puts "ticker = #{currency.ticker}"
  puts "depth = #{currency.depth}"
  puts "depth = #{currency.depth}"
  puts ''
end


