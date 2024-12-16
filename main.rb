require 'webrick'
require 'json'
require_relative 'handlers/user'

SQLiteDatabase.new.drop_users_table_sql

server = WEBrick::HTTPServer.new(Port: 6006, BindAddress: '0.0.0.0')
server.mount '/', UserHandler
trap('INT') { server.shutdown }
server.start
