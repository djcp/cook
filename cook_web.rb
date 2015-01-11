require 'sinatra'
require 'sqlite3'
require 'chartkick'

db = SQLite3::Database.new "./db/temperatures.db"
db.busy_timeout = 1000

get '/' do
  db.query('select id, name, desired_temp from dishes where enabled = "true"').each_hash do |row|
    @active_dish = row
  end
  desired = {}
  actual = {}
  db.transaction do
    db.execute(
      "SELECT temperatures.read_time, temperatures.desired_temp, temperatures.actual_temp
      FROM temperatures, dishes
      WHERE dishes.enabled = 'true' and
      dishes.id = temperatures.dish_id
      GROUP BY strftime('%Y%m%d%H%M', temperatures.read_time)
      ORDER BY temperatures.read_time, temperatures.actual_temp"
    ).each do |row|
      desired[row[0]] = row[1]
      actual[row[0]] = row[2]
    end
  end
  if desired.length > 0
    @max = [desired.values.first, actual.values.max].max + 5
    @min = [desired.values.min, actual.values.min].min - 5
    @chart_data = [
      { name: 'Desired Temp', data: desired },
      { name: 'Actual Temp', data: actual }
    ]
  end
  erb :index
end

post '/dishes/stop_cooking' do
  db.transaction do
    db.execute('UPDATE dishes SET enabled = "false"')
  end
  redirect '/'
end

post '/dishes' do
  name = params[:name]
  desired_temp = (params[:desired_temp] || 57.2).to_f
  notes = params[:notes]

  db.transaction do
    db.execute('UPDATE dishes SET enabled = "false"')
    db.execute(
      'INSERT INTO dishes(name, desired_temp, notes, enabled) values(?, ?, ?, "true")',
      [name, desired_temp, notes]
    )
  end
  redirect '/'
end
