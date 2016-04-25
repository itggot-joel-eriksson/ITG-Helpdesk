class Upload
    include DataMapper::Resource

    property :id, Serial
    property :uuid, String, required: true, unique: true
    property :file, FilePath, required: true
    property :created_at, EpochTime

    belongs_to :issue
    belongs_to :user
end
