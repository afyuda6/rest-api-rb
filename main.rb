require 'json'
require_relative 'handlers/user'

SQLiteDatabase.new.drop_users_table_sql

class HTTPServer
  def initialize(host, port)
    @server = TCPServer.new(host, port)
    @handler = UserHandler.new
  end

  def start
    loop do
      client = @server.accept
      request = client.readpartial(1024)
      response = @handler.handle_request(request)

      client.write("HTTP/1.1 #{response[:status]} OK\r\n")
      response[:headers].each { |key, value| client.write("#{key}: #{value}\r\n") }
      client.write("\r\n")
      client.write(response[:body])
      client.close
    end
  end
end

server = HTTPServer.new('127.0.0.1', 6006)
server.start