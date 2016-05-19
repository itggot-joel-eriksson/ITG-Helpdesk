class User
    include DataMapper::Resource

    property :id, Serial
    property :uuid, String, required: true, unique: true
    property :email, String, required: true, unique: true, format: :email_address
    property :serial_number, String, unique: true
    property :custom_email, String, format: :email_address
    property :name, String
    property :given_name, String
    property :family_name, String
    property :avatar, URI
    property :blocked, Boolean, default: false
    property :active, Boolean, default: false
    property :permission, Enum[:student, :teacher, :admin], default: :student
    property :created_at, EpochTime

    has n, :issues
    has n, :faqs
    has n, :attachments
    has n, :events

    def self.authorize(app:, params:)
        client_secrets = Google::APIClient::ClientSecrets.load || Google::APIClient::ClientSecrets.new(JSON.parse(ENV["GOOGLE_CLIENT_SECRETS"]))
        auth_client = client_secrets.to_authorization
        auth_client.update!(
            scope: ["https://www.googleapis.com/auth/plus.me", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/admin.directory.user", "https://www.googleapis.com/auth/admin.directory.user.readonly"],
            redirect_uri: app.url("/oauth2callback")
        )
        if params[:code] == nil
            auth_uri = auth_client.authorization_uri.to_s
            return auth_uri
        else
            auth_client.code = params[:code]
            auth_client.fetch_access_token!
            auth_client.client_secret = nil

            access_token = auth_client.access_token.to_s
            user_info = Unirest.get "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=#{access_token}"
            app.session[:google_user] = user_info.body
            app.session[:access_token] = access_token

            return user_info.body, access_token
        end
    end

    def self.revoke(app:, access_token:)
        Unirest.get "https://accounts.google.com/o/oauth2/revoke", params: { :token => access_token }
        app.session.destroy
    end

    def self.delete(app:, user:, params:)
        return throw_error(app: self, code: 403, message: "forbidden") unless user.permission == :admin
        remove_user = User.first(uuid: params[:user])
        if remove_user
            if remove_user.permission == :admin
                app.flash[:tab] = :admins
                return throw_error(app: self, code: 400, message: "bad request") if User.all(permission: :admin).count <= 1
            elsif remove_user.permission == :teacher
                app.flash[:tab] = :teachers
            else
                app.flash[:tab] = :students
            end

            # remove files
            # remove settings
            # remove events
            # if remove_user is an admin make another admin delete that admin as well
            Issue.delete_all(app: self, user: user, user_id: remove_user.id)
            # Issue.all(user_id: remove_user.id).destroy!
            # Attachment.all(user_id: remove_user.id).destroy!
            remove_user.destroy!
        else
            return throw_error(app: self, code: 404, message: "not found")
        end
    end
end
