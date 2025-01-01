require 'sqlite3'

class SQLiteDatabase
  def initialize
    @db = SQLite3::Database.new "rest_api_rb.db"
    create_users_table_sql
  end

  def connection
    @db
  end

  def drop_users_table_sql
    @db.execute <<-SQL
        DROP TABLE IF EXISTS users;
    SQL
  end

  def create_users_table_sql
    @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
        );
    SQL
  end
end