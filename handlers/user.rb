require 'json'
require 'cgi'
require_relative '../database/sqlite'

class UserHandler
  def handle_read_users
    result = @db.connection.execute("SELECT id, name FROM users")
    data = result.map { |row| { id: row[0], name: row[1] } }
    { status: 200, headers: { "Content-Type" => "application/json" }, body: { status: "OK", code: 200, data: data }.to_json }
  end

  def handle_create_user(body)
    form_data = parse_request_body(body)
    if form_data['name'].nil? || form_data['name'].strip.empty?
      return { status: 400, headers: { "Content-Type" => "application/json" }, body: { status: "Bad Request", code: 400, errors: "Missing 'name' parameter" }.to_json }
    end
    @db.connection.execute("INSERT INTO users (name) VALUES (?)", form_data['name'])
    { status: 201, headers: { "Content-Type" => "application/json" }, body: { status: "Created", code: 201 }.to_json }
  end

  def handle_update_user(body)
    form_data = parse_request_body(body)
    if form_data['name'].nil? || form_data['id'].nil?
      return { status: 400, headers: { "Content-Type" => "application/json" }, body: { status: "Bad Request", code: 400, errors: "Missing 'id' or 'name' parameter" }.to_json }
    end
    if form_data['name'].strip.empty? || form_data['id'].strip.empty?
      return { status: 400, headers: { "Content-Type" => "application/json" }, body: { status: "Bad Request", code: 400, errors: "Missing 'id' or 'name' parameter" }.to_json }
    end
    @db.connection.execute("UPDATE users SET name = ? WHERE id = ?", [form_data['name'], form_data['id']])
    { status: 200, headers: { "Content-Type" => "application/json" }, body: { status: "OK", code: 200 }.to_json }
  end

  def handle_delete_user(body)
    form_data = parse_request_body(body)
    if form_data['id'].nil? || form_data['id'].strip.empty?
      return { status: 400, headers: { "Content-Type" => "application/json" }, body: { status: "Bad Request", code: 400, errors: "Missing 'id' parameter" }.to_json }
    end
    @db.connection.execute("DELETE FROM users WHERE id = ?", form_data['id'])
    { status: 200, headers: { "Content-Type" => "application/json" }, body: { status: "OK", code: 200 }.to_json }
  end

  def handle_request(request)
    method = request.request_method
    path = request.path_info
    body = request.body.read
    if path == '/users' || path == '/users/'
      case method
      when 'GET'
        handle_read_users
      when 'POST'
        handle_create_user(body)
      when 'PUT'
        handle_update_user(body)
      when 'DELETE'
        handle_delete_user(body)
      else
        { status: 405, headers: { "Content-Type" => "application/json" }, body: { status: "Method Not Allowed", code: 405 }.to_json }
      end
    else
      { status: 404, headers: { "Content-Type" => "application/json" }, body: { status: "Not Found", code: 404 }.to_json }
    end
  end

  def initialize
    @db = SQLiteDatabase.new
  end

  private

  def parse_request_body(body)
    return {} if body.nil? || body.strip.empty?
    CGI.parse(body).transform_values { |v| v.is_a?(Array) && v.length == 1 ? v.first : v }
  end
end
