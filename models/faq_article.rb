class FAQ
    include DataMapper::Resource

    property :id, Serial
    property :question, Text, required: true
    property :answer, Text, required: true
    property :created_at, DateTime
    property :user_id, Integer, required: true
end
