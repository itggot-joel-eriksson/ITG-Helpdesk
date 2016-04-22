class User
    include DataMapper::Resource

    property :id, Serial
    property :uuid, UUID, default: UUIDTools::UUID.random_create
    property :email, String, required: true, unique: true
    property :custom_email, String
    property :blocked, Boolean, default: false
    property :permission_admin, Boolean, default: false
    property :permission_teacher, Boolean, default: false

    has n, :issues
    has n, :faqs
end
