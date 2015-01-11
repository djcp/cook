require 'rubygems'
require './lib/temperature_reader'
require 'bundler/setup'
require 'pi_piper'
require 'sqlite3'

db = SQLite3::Database.new "./db/temperatures.db"
db.busy_timeout = 1000

pin = PiPiper::Pin.new(:pin => 23, :direction => :out)
temp_reader = TemperatureReader.new

# 57.2 celcius =~ 135 F, or medium rare.

desired_temp = (ENV['DESIRED_TEMP'] || 57.2).to_f

begin
  while true do
    active_dish = db.get_first_row('select id, desired_temp from dishes where enabled = "true"')
    if active_dish
      dish_id = active_dish.first
      desired_temp = active_dish[1]
      temp_reader.read
      if temp_reader.valid_reading?
        db.transaction do
          db.execute(
            "INSERT INTO temperatures (dish_id, read_time, desired_temp, actual_temp) VALUES (?, datetime('now'), ?, ?)",
            [dish_id, desired_temp, temp_reader.temperature]
          )
        end
        if temp_reader.temperature < desired_temp
          pin.on
        else
          pin.off
        end
      end
    else
      pin.off
    end
    sleep 5
  end
rescue => e
  puts e.inspect
ensure
  db.close
  pin.off
end
