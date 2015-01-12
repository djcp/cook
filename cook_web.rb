require 'sinatra'
require 'sqlite3'
require 'chartkick'

helpers do
  def db
    @db_handle ||= SQLite3::Database.new "./db/temperatures.db"
    @db_handle.busy_timeout = 1000
    @db_handle
  end

  def get_active_dish
    active_dish = nil
    db.query('SELECT id, name, desired_temp FROM dishes WHERE enabled = "true"').each_hash do |row|
      active_dish = row
    end
    active_dish
  end

  def get_temps_for_dish(dish_id)
    desired = {}
    actual = {}
    db.transaction do
      db.execute(%Q|
        SELECT temperatures.read_time, temperatures.desired_temp, temperatures.actual_temp
        FROM temperatures, dishes
        WHERE dishes.enabled = 'true' and
          dishes.id = temperatures.dish_id and
          dishes.id = ?
          GROUP BY strftime('%Y%m%d%H%M', temperatures.read_time)
        ORDER BY temperatures.read_time, temperatures.actual_temp|,
          [dish_id]
                ).each do |row|
                  desired[row[0]] = row[1]
                  actual[row[0]] = row[2]
                end
    end
    { desired: desired, actual: actual }
  end
end

get '/' do
  @active_dish = get_active_dish
  # Doing these as separate statement should be optimized by the 
  # query planner according to the docs
  if @active_dish
    @min = db.get_first_value(
      'select min(actual_temp) - 5 from temperatures where dish_id = ?',
      [@active_dish['id']]
    )
    @max = db.get_first_value(
      'select max(desired_temp) + 5 from temperatures where dish_id = ?',
      [@active_dish['id']]
    )
  end
  erb :index
end

get '/temperatures/:id' do
  content_type :json
  temp_values = get_temps_for_dish(params[:id])

  if temp_values[:desired].length > 0
    chart_data = [
      { name: 'Desired Temp', data: temp_values[:desired] },
      { name: 'Actual Temp', data: temp_values[:actual] }
    ]
    return chart_data.to_json
  end
  [].to_json
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
