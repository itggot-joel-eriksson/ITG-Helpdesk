class Comment
    include DataMapper::Resource

    property :id, Serial
    property :uuid, String, required: true, unique: true
end
