require 'cgi'
require 'json'
require 'sqlite3'
require_relative '../database/sqlite'

class UserHandler < WEBrick::HTTPServlet::AbstractServlet
  def handle_read_users(response)
    result = @db.connection.execute("SELECT id, name FROM users")
    result.map { |row| { id: row[0], name: row[1] } }
    response.status = 200
    response.body = { status: "OK", code: 200, data: result }.to_json
  end

  def handle_create_user(request, response)
    form_data = parse_request_body(request)
    if form_data['name'].nil? || form_data['name'].strip.empty?
      response.status = 400
      response.body = { status: "Bad Request", code: 400, errors: "Missing 'name' parameter" }.to_json
      return
    end
    @db.connection.execute("INSERT INTO users (name) VALUES (?)", form_data['name'])
    response.status = 201
    response.body = { status: "Created", code: 201 }.to_json
  end

  def handle_update_user(request, response)
    form_data = parse_request_body(request)
    if form_data['name'].nil? || form_data['id'].nil?
      response.status = 400
      response.body = { status: "Bad Request", code: 400, errors: "Missing 'id' or 'name' parameter" }.to_json
      return
    end
    if form_data['name'].strip.empty? || form_data['id'].strip.empty?
      response.status = 400
      response.body = { status: "Bad Request", code: 400, errors: "Missing 'id' or 'name' parameter" }.to_json
      return
    end
    @db.connection.execute("UPDATE users SET name = ? WHERE id = ?", [form_data['name'], form_data['id']])
    response.status = 200
    response.body = { status: "OK", code: 200 }.to_json
  end

  def handle_delete_user(request, response)
    form_data = parse_request_body(request)
    if form_data['id'].nil? || form_data['id'].strip.empty?
      response.status = 400
      response.body = { status: "Bad Request", code: 400, errors: "Missing 'id' parameter" }.to_json
      return
    end
    @db.connection.execute("DELETE FROM users WHERE id = ?", form_data['id'])
    response.status = 200
    response.body = { status: "OK", code: 200 }.to_json
  end

  def service(request, response)
    response['Content-Type'] = 'application/json'
    if request.path == '/users' or request.path == '/users/'
      case request.request_method
      when 'GET'
        handle_read_users(response)
      when 'POST'
        handle_create_user(request, response)
      when 'PUT'
        handle_update_user(request, response)
      when 'DELETE'
        handle_delete_user(request, response)
      else
        response.status = 405
        response.body = { status: 'Method Not Allowed', code: 405 }.to_json
      end
    else
      response.status = 404
      response.body = { status: 'Not Found', code: 404 }.to_json
    end
  end

  def initialize(server)
    super(server)
    @db = SQLiteDatabase.new
  end

  private

  def parse_request_body(request)
    body = request.body.nil? ? '' : request.body
    CGI.parse(body).transform_values { |v| v.is_a?(Array) && v.length == 1 ? v.first : v }
  end
end
