class Comment
	include DataMapper::Resource

	property :id, String, :key => true # id == comment_id
	property :comment, String, :required => true

	belongs_to :user, :required => false
end
