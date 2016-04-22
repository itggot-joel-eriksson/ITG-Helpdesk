class Upload
    include DataMapper::Resource

    property :id, Serial
    property :uuid, UUID, default: UUIDTools::UUID.random_create
end
