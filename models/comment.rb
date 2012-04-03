require 'data_mapper'

class Comment
	include DataMapper::Resource
	property :id,	Serial
	property :fbid, String, :required => true
	property :fbuid, String, :required => true
	property :comment, String, :required => true
end
