$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/lib')
require 'util'
require 'pry-byebug'

arr = []
File.open(pre_log_file('executions'), 'r') do |f|
  f.each_line do |line|
    arr << eval(line)
  end
end

buy_sum = 0.0
sell_sum = 0.0
arr.each do |a|
  buy_sum += (a['size'] * a['price']) if a['side'] == 'BUY'
  sell_sum += (a['size'] * a['price']) if a['side'] == 'SELL'
end

total = buy_sum + sell_sum

time = time_cut(Time.now)
prices = `grep "#{time}" log/price.log | cut -f2 -d ","`
price = prices.split("\n")[0]
File.open(csv_file('executions'), 'a') do |f|
  f.puts "#{buy_sum.to_i},#{sell_sum.to_i},#{total.to_i},#{price.to_i}"
end