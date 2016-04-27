class Category
	include DataMapper::Resource

	property :id, Serial
	property :uuid, String, required: true, unique: true
	property :title, String, required: true, unique: true

	has n, :issues, :through => Resource
end
