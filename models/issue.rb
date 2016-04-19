class Issue
	include DataMapper::Resource

	property :id, Serial
	property :title, String, required: true
	property :description, Text, required: true
	property :created_at, DateTime
	property :user_id, Integer, required: true

end
