require 'rubygems'
require './lib/temperature_reader'
require 'bundler/setup'
require 'pi_piper'
require 'sqlite3'

db = SQLite3::Database.new "./db/temperatures.db"

pin = PiPiper::Pin.new(:pin => 23, :direction => :out)
temp_reader = TemperatureReader.new

# 57.2 celcius =~ 135 F, or medium rare.

desired_temp = (ENV['DESIRED_TEMP'] || 57.2).to_f

begin
  while true do
    temp_reader.read
    if temp_reader.valid_reading?
      db.execute("INSERT INTO temperatures (read_time, desired_temp, actual_temp) VALUES (?, ?, ?)", 
        [Time.now.to_s, desired_temp, temp_reader.temperature]
      )
      if temp_reader.temperature < desired_temp
        pin.on
      else
        pin.off
      end
    end
    sleep 5
  end
rescue => e
  puts e.inspect
ensure
  db.close
  pin.off
end
