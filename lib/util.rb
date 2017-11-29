def up_rate(num)
  1 + percent(num)
end

def down_rate(num)
  1 - percent(num)
end

def percent(num)
  num / 100.to_f
end

def log_file(str, min_unit = 1)
  now = Time.now
  log_file_by(str, now, min_unit)
end

def pre_log_file(str, min_unit = 1)
  now = Time.now - (min_unit * 60)
  log_file_by(str, now, min_unit)
end

def log_file_by(str, now, min_unit)
  remain = now.min % min_unit
  m = "%02d" % (now.min - remain)
  dir = "log/#{str}/#{now.year}#{now.month}#{now.day}"
  `mkdir -p #{dir}`
  "#{dir}/#{now.hour}#{m}.log"
end

def time_cut(now, min_unit = 1)
  remain = now.min % min_unit
  m = "%02d" % (now.min - remain)
  "#{now.year}/#{now.month}/#{now.day} #{now.hour}:#{m}"
end

def csv_file(str)
  `mkdir -p csv`
  "csv/#{str}.csv"
end
