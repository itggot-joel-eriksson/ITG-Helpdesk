class Issue
	include DataMapper::Resource

	property :id, Serial
	property :uuid, UUID, default: UUIDTools::UUID.random_create
	property :title, String, required: true
	property :description, Text, required: true
	property :created_at, DateTime

	belongs_to :user
end
