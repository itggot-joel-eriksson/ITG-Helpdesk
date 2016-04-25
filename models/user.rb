class User
    include DataMapper::Resource

    property :id, Serial
    property :uuid, String, required: true, unique: true
    property :email, String, required: true, unique: true, format: :email_address
    property :custom_email, String

    property :name, String
    property :avatar, URI

    property :blocked, Boolean, default: false
    property :permission_admin, Boolean, default: false
    property :permission_teacher, Boolean, default: false

    has n, :issues
    has n, :faqs
    has n, :uploads
end
