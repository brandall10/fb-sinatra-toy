require 'sinatra'
require 'data_mapper'
require 'koala'
require 'haml'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

APP_ID = 356300754405030
APP_SECRET = 'a7504467c9357caf0fde23c88071bea8'
SITE_UR = 'http://localhost:9393/' 

class Comment
	include DataMapper::Resource
	property :id,	Serial
	property :fbid, String, :required => true
	property :comment, String, :required => true
end
DataMapper.finalize

get '/' do
	@comments = Comment.all
	haml :index
end

#post '/'
#	Comment.create params[:comment]
#	redirect to('/')
#end

#delete '/comment/:id'
#	Comment.get(params[:id]).destroy
#	redirect to('/')
#end
