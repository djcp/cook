require 'sqlite3'

db = SQLite3::Database.new "./db/temperatures.db"

# Create a database
db.execute('drop table temperatures;')

db.execute %Q|
  create table temperatures (
    read_time datetime,
    desired_temp float,
    actual_temp float
  );
|
db.close
