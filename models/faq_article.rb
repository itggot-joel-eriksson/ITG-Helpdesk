class Faq
    include DataMapper::Resource

    property :id, Serial
    property :uuid, UUID, default: UUIDTools::UUID.random_create
    property :question, Text, required: true
    property :answer, Text, required: true
    property :created_at, DateTime

    belongs_to :user
end
