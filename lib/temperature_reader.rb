class TemperatureReader
  attr_reader :data

  def read
    @data = File.read(
      Dir.glob('/sys/bus/w1/devices/28-*/w1_slave').first
    ).split(/\n/)
  end
  
  def valid_reading?
    @data.first.match(/YES$/)
  end

  def temperature
    (@data.last.split('=')[1]).to_f / 1000
  end
end
