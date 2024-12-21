require 'thin'
require 'json'
require_relative 'handlers/user'

SQLiteDatabase.new.drop_users_table_sql

class App
  def call(env)
    request = Rack::Request.new(env)
    handler = UserHandler.new
    response = handler.handle_request(request)
    [
      response[:status],
      response[:headers],
      [response[:body]]
    ]
  end
end

port = ENV['PORT'] ? ENV['PORT'].to_i : 6006

Thin::Server.start('0.0.0.0', port) do
  run App.new
end