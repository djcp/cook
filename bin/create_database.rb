require 'sqlite3'

db = SQLite3::Database.new "./db/temperatures.db"

# Create a database
db.execute('drop table temperatures;')

db.execute %Q|
create table temperatures (
  dish_id integer,
  read_time datetime,
  desired_temp float,
  actual_temp float
);
|

db.execute('drop table dishes;')
db.execute %Q|
create table dishes (
  id INTEGER PRIMARY KEY,
  name varchar,
  desired_temp float,
  notes varchar,
  enabled boolean
);
|

db.close
