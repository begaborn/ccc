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
  puts "opening_price = #{currency.opening_price}"
  puts "closing_price = #{currency.closing_price}"
  puts "high_price = #{currency.high_price}"
  puts "low_price = #{currency.low_price}"
  puts "bab_rate = #{currency.bab_rate}"
  puts "vpin = #{currency.vpin}"
  puts "buy_rate = #{currency.latest_buy_rate}"
  puts "sell_rate = #{currency.latest_sell_rate}"
  puts "price_round_down = #{currency.price_round_down(12345.12345)}"
  puts "amount_round_down = #{currency.amount_round_down(123.12345678901)}"
  puts "price = #{currency.price}"
  puts "volume = #{currency.volume24h}"
  amount = currency.buyable_amount(limit_cash: 1000, price: currency.price * 0.7)
  order_id = currency.stickily_buy amount, price: currency.price * 0.8
  puts "order_id = #{order_id}"
  currency.reload
  puts "my_orders = #{currency.my_orders}"
  puts "find_order = #{currency.find_order(order_id)}"
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
  currency.all_cancel
  #res = currency.stickily_cancel order_id
  #puts "canceled order_id = #{res}"
  currency.reload
  puts "my_orders = #{currency.my_orders}"
  puts ''
  sleep 1
end