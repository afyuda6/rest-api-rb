require 'thin'
require 'json'
require_relative 'handlers/user'

SQLiteDatabase.new.drop_users_table_sql

class App
  def call(env)
    request = Rack::Request.new(env)
    if request.request_method == 'OPTIONS'
      return [200, { 'Access-Control-Allow-Origin' => '*',
                     'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
                     'Access-Control-Allow-Headers' => 'Content-Type' }, []]
    end
    handler = UserHandler.new
    response = handler.handle_request(request)
    response[:headers]['Access-Control-Allow-Origin'] = '*'
    response[:headers]['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    response[:headers]['Access-Control-Allow-Headers'] = 'Content-Type'
    [
      response[:status],
      response[:headers],
      [response[:body]]
    ]
  end
end

port = ENV['PORT'] ? ENV['PORT'].to_i : 6001

Thin::Server.start('0.0.0.0', port) do
  run App.new
end