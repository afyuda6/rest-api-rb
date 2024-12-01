require 'thin'
require 'json'
require_relative 'handlers/user'

SQLiteDatabase.new.drop_table_if_exists

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new

  normalized_path = req.path_info.chomp('/')

  handler = UserHandler.new

  if normalized_path =~ %r{^/users/([^/]+)$} || normalized_path == "/users"
    case req.request_method
    when "GET"
      res.content_type = "application/json"
      handler.do_GET(res)
    when "POST"
      res.content_type = "application/json"
      handler.do_POST(req, res)
    when "PUT"
      res.content_type = "application/json"
      handler.do_PUT(req, res)
    when "DELETE"
      res.content_type = "application/json"
      handler.do_DELETE(req, res)
    else
      res.status = 405
      res.content_type = "application/json"
      res.write({ status: "Method Not Allowed", code: 405 }.to_json)
    end
  else
    res.status = 404
    res.content_type = "application/json"
    res.write({ status: "Not Found", code: 404 }.to_json)
  end

  res.finish
end

Thin::Server.start('0.0.0.0', 6006, app)
