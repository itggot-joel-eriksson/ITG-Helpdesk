class Category
	include DataMapper::Resource 

	property :id, Serial
	property :title, String, required: true, unique: true
end