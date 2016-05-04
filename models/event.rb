class Event
    include DataMapper::Resource

    property :id, Serial
    property :uuid, String, required: true, unique: true
    property :title, String
    property :content, String
    property :type, Enum[:open, :close, :reopen, :comment], required: true
    property :created_at, EpochTime

    belongs_to :user
    belongs_to :issue
end
