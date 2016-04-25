class Issue
	include DataMapper::Resource

	property :id, Serial
	property :uuid, String, required: true, unique: true
	property :title, String, required: true
	property :description, Text, required: true
	property :created_at, EpochTime

	belongs_to :user
	has n, :uploads
end
