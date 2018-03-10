$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'
require 'my_bitbank'

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end

Bitbank.currencies.each do |c|
  currency = Bitbank.send(c.to_sym)
  puts '-----------------------------------'
  puts "client = #{currency.client}"
  puts "config = #{currency.conf}"
  puts "currency_code = #{currency.currency_code}"
  puts "default_pair = #{currency.default_pair}"
  puts "currency_pair = #{currency.currency_pair}"
  puts "price = #{currency.price}"
  puts "volume = #{currency.volume24h}"
  currency.reload
  puts "balance = #{currency.balance}"
  puts "locked_balance = #{currency.locked_balance}"
  puts "available_balance = #{currency.available_balance}"
  puts "balance_pair = #{currency.balance_pair}"
  puts "locked_balance_pair = #{currency.locked_balance_pair}"
  puts "available_balance_pair = #{currency.available_balance_pair}"
  puts "to_pair = #{currency.to_pair}"
  puts "maker fee = #{currency.maker_fee}"
  puts "taker fee = #{currency.taker_fee}"
  puts "withdrawal fee = #{currency.withdrawal_fee}"
  puts "orderable_amount = #{currency.orderable_amount}"
  puts "sellable_amount = #{currency.sellable_amount}"
  puts "buyable_amount = #{currency.buyable_amount}"
  puts "my_orders = #{currency.my_orders}"
  puts ''
  sleep 1
end