require 'sqlite3'
db = SQLite3::Database.new "./db/temperatures.db"

# Create a database
db.execute('drop table if exists temperatures')

db.execute(%Q|
create table temperatures (
  dish_id integer,
  read_time datetime,
  desired_temp float,
  actual_temp float
)|)

db.execute(%Q|
create index 'temperatures_dish_id_idx' on temperatures(dish_id);
|)

db.execute(%Q|
create index 'temperatures_desired_temp_idx' on temperatures(desired_temp);
|)

db.execute(%Q|
create index 'temperatures_actual_temp_idx' on temperatures(actual_temp);
|)

db.execute('drop table if exists dishes')
db.execute %Q|
create table dishes (
  id INTEGER PRIMARY KEY,
  name varchar,
  desired_temp float,
  notes varchar,
  enabled boolean
)|

db.close
