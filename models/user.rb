class User 
	include DataMapper::Resource

	property :id, String, :key => true # id == fb_uid	
	property :name, String, :required => true

	has n, :comments
end
