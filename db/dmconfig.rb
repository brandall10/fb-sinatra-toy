require 'data_mapper'
require './models/user'
require './models/comment'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/development.db")

DataMapper.finalize
DataMapper.auto_upgrade!
