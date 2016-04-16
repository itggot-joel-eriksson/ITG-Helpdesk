class Issue
	include DataMapper::Resource
	
	property :id, Serial
	property :title, required: true
	property :description, required: true
	
end