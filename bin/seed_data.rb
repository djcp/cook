require 'sqlite3'
db = SQLite3::Database.new "./db/temperatures.db"

db.execute(
  'INSERT INTO dishes(name, desired_temp, notes, enabled) values(?, ?, ?, "true")',
  ['Test', 57.2, '']
)
dish_id = db.get_first_value('select id from dishes')

(1..10).to_a.each do |fragment|
  db.execute(
    "INSERT INTO temperatures (dish_id, read_time, desired_temp, actual_temp) VALUES (?, datetime('now', '+#{fragment} minute'), ?, ?)",
    [dish_id, 57.2, 49.0 + fragment]
  )
end
