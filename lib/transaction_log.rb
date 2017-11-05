require 'fileutils'
class TransactionLog
  @@log_dir = 'log'
  @@log_file = "#{@@log_dir}/transaction.rb"

  def self.all 
    data = []
    begin
      File.open(@@log_file, 'r').each_line do |line|
        data << eval(line) 
      end
    rescue
    end
    data
  end

  def self.save(data)
    create_log_file unless File.exist?(@@log_file)
    File.open(@@log_file, 'a') do |f| 
      f.puts data
    end
  end

  private

  def self.create_log_file
    FileUtils.mkdir(@@log_dir) unless File.exist?(@@log_dir)
    FileUtils.touch(@@log_file)
  end
end
