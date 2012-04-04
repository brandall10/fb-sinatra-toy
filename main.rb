require 'sinatra'
require 'data_mapper'
require 'koala'
require 'haml'
require './db/dmconfig'

APP_ID = 356300754405030
APP_SECRET = 'a7504467c9357caf0fde23c88071bea8'
SITE_URL = 'http://localhost:9393/' 

include Koala
enable :sessions

get '/' do
	if session['access_token']
		user = User.get(session['user_id'])
		@comments = user.comments
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
	session['user_id'] = nil

	redirect '/'
end

get '/callback' do
	# store authentication token, graph api ptr, and fb user info
	session['access_token'] = session['oauth'].get_access_token(params[:code])
	session['graph'] = Facebook::API.new (session['access_token'])
	me = session['graph'].get_object('me')
	
	# create or fetch user record from db, save off for session 
	user = User.first_or_create( {:id => me['id']}, {:name => me['name']} )
	session['user_id'] = user.id
	redirect '/'
end

post '/' do
	# must pull back facebook's object id so we can modify afterward, take note to pull from hash
	# write to both facebook and db to keep parity
	post_id =  session['graph'].put_wall_post(params[:comment][:comment])['id']
	params[:comment][:id] = post_id
	user = User.get(session['user_id'])
	user.comments.create(params[:comment])
	redirect '/'
end

delete '/comment/:id' do
	comment = Comment.get(params[:id])

	# delete both from facebook and the database
	session['graph'].delete_object(comment.id)
	comment.destroy

	redirect '/'
end
