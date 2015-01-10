require 'sinatra'
require 'sqlite3'
require 'chartkick'
set :bind, "0.0.0.0"

db = SQLite3::Database.new "./db/temperatures.db"

get '/' do
  desired = {}
  actual = {}
  db.execute('select read_time, desired_temp, actual_temp from temperatures').each do |row|
    desired[row[0]] = row[1]
    actual[row[0]] = row[2]
  end
  @chart_data = [
    { name: 'Desired Temp', data: desired },
    { name: 'Actual Temp', data: actual }
  ]
  erb :index	
end

