require 'sinatra'
require 'data_mapper'
require 'koala'
require 'haml'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

APP_ID = 356300754405030
APP_SECRET = 'a7504467c9357caf0fde23c88071bea8'
SITE_URL = 'http://localhost:9393/' 

class Comment
	include DataMapper::Resource
	property :id,	Serial
	property :fbid, String, :required => true
	property :comment, String, :required => true
end
DataMapper.finalize

include Koala
enable :sessions

get '/' do
	if session['access_token']
		@comments = Comment.all
		haml :index
	else
		haml :login
	end
end

get '/login' do
	session['oauth'] = Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + 'callback')
	redirect session['oauth'].url_for_oauth_code(:permissions => "publish_stream")	
end

get '/logout' do
	session['oauth'] = nil
	session['access_token'] = nil
	redirect '/'
end

get '/callback' do
	session['access_token'] = session['oauth'].get_access_token(params[:code])
	redirect '/'
end

post '/' do
	@graph = Facebook::API.new (session['access_token'])
	@graph.put_wall_post(params[:comment][:comment])
	Comment.create params[:comment]
	redirect '/'
end

delete '/comment/:id' do
	Comment.get(params[:id]).destroy
	redirect '/'
end
