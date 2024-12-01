require 'sqlite3'

class SQLiteDatabase
  def initialize
    @db = SQLite3::Database.new "rest_api_rb.db"
    create_table_if_not_exists
  end

  def drop_table_if_exists
    @db.execute <<-SQL
        DROP TABLE IF EXISTS users;
    SQL
  end

  def create_table_if_not_exists
    @db.execute <<-SQL
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL
        );
    SQL
  end

  def handle_read_users
    result = @db.execute("SELECT id, name FROM users")
    result.map { |row| { id: row[0], name: row[1] } }
  end

  def handle_create_user(name)
    @db.execute("INSERT INTO users (name) VALUES (?)", name)
  end

  def handle_update_user(name, id)
    @db.execute("UPDATE users SET name = ? WHERE id = ?", [name, id])
  end

  def handle_delete_user(id)
    @db.execute("DELETE FROM users WHERE id = ?", id)
  end
end
