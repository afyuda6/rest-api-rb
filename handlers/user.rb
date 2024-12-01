require 'json'
require_relative '../database/sqlite'

class UserHandler
  def initialize
    @db = SQLiteDatabase.new
  end

  def do_GET(response)
    users = @db.handle_read_users
    response.status = 200
    response.write({ status: "OK", code: 200, data: users }.to_json)
  end

  def do_POST(request, response)
    form_data = Rack::Utils.parse_query(request.body.read)

    if form_data['name'].nil?
      response.status = 400
      response.write({ status: "Bad Request", code: 400, errors: "Missing 'name' parameter" }.to_json)
      return
    end

    @db.handle_create_user(form_data['name'])

    response.status = 201
    response.write({ status: "Created", code: 201 }.to_json)
  end

  def do_PUT(request, response)
    form_data = Rack::Utils.parse_query(request.body.read)

    if form_data['name'].nil? or form_data['id'].nil?
      response.status = 400
      response.write({ status: "Bad Request", code: 400, errors: "Missing 'id' or 'name' parameter" }.to_json)
      return
    end

    @db.handle_update_user(form_data['name'], form_data['id'])

    response.status = 200
    response.write({ status: "OK", code: 200 }.to_json)
  end

  def do_DELETE(request, response)
    form_data = Rack::Utils.parse_query(request.body.read)

    if form_data['id'].nil?
      response.status = 400
      response.write({ status: "Bad Request", code: 400, errors: "Missing 'id' parameter" }.to_json)
      return
    end

    @db.handle_delete_user(form_data['id'])

    response.status = 200
    response.write({ status: "OK", code: 200 }.to_json)
  end
end
