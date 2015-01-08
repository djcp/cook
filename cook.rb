require 'rubygems'
require './lib/temperature_reader'
require 'bundler/setup'
require 'pi_piper'

pin = PiPiper::Pin.new(:pin => 23, :direction => :out)
temp_reader = TemperatureReader.new

# 57.2 celcius =~ 135 F, or medium rare.

desired_temp = (ENV['DESIRED_TEMP'] || 57.2).to_f

begin
  while true do
    temp_reader.read
    if temp_reader.valid_reading?
      if temp_reader.temperature < desired_temp
        puts "Turning on: want #{desired_temp}, at #{temp_reader.temperature}"
        pin.on
      else
        puts "Turning off: want #{desired_temp}, at #{temp_reader.temperature}"
        pin.off
      end
    end
    sleep 5
  end
rescue => e
  puts e.inspect
ensure
  pin.off
end
