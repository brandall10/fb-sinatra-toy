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
	property :fbuid, String, :required => true
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
	# if user does not have an open facebook session they will be automatically directed to facebook, callback will define what happens after
	session['oauth'] = Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + 'callback')
	# must set publish_stream to modify wall feed
	redirect session['oauth'].url_for_oauth_code(:permissions => "publish_stream")	
end

get '/logout' do
	session['oauth'] = nil
	session['access_token'] = nil
	session['graph'] = nil
	redirect '/'
end

get '/callback' do
	session['access_token'] = session['oauth'].get_access_token(params[:code])
	session['graph'] = Facebook::API.new (session['access_token'])
	redirect '/'
end

post '/' do
	# must pull back facebook's object id so we can modify afterward, take note to pull from hash
	# write to both facebook and db to keep parity
	fbid =  session['graph'].put_wall_post(params[:comment][:comment])["id"]
	params[:comment][:fbid] = fbid
	Comment.create params[:comment]
	redirect '/'
end

delete '/comment/:id' do
	comment = Comment.get(params[:id])
	# delete both from facebook and the database
	session['graph'].delete_object(comment.fbid)
	comment.destroy
	redirect '/'
end
