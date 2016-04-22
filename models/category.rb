class Category
	include DataMapper::Resource

	property :id, Serial
	property :uuid, UUID, default: UUIDTools::UUID.random_create
	property :title, String, required: true, unique: true
end
