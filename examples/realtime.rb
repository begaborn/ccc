$:.unshift(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'pry-byebug'
require 'ccc'

Ccc.configure do |config|
  config.yml_filename = File.dirname(File.expand_path(__FILE__)) + '/ccc.yml'
end

autoload(:Zaif, 'my_zaif')
eth = Zaif.btc
reader, writer = IO.pipe
# reader => #<IO:fd 7>
# writer => #<IO:fd 8>

# forkにより子プロセスを生成
fork do
  reader.close
  eth.stream(writer)
end

writer.close
while message = reader.gets
  $stdout.puts eval(message)[:trades]
end