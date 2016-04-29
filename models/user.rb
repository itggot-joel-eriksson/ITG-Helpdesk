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
    has n, :attachments

    def self.authorize(app:, params:)
        client_secrets = Google::APIClient::ClientSecrets.load
        auth_client = client_secrets.to_authorization
        auth_client.update!(
            scope: ["https://www.googleapis.com/auth/plus.me", "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/userinfo.email"],
            redirect_uri: app.url("/oauth2callback")
        )
        if params[:code] == nil
            auth_uri = auth_client.authorization_uri.to_s
            return auth_uri
        else
            auth_client.code = params[:code]
            auth_client.fetch_access_token!
            auth_client.client_secret = nil
            app.session[:credentials] = auth_client.to_json

            access_token = auth_client.access_token.to_s
            user_info = Unirest.get "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=#{access_token}"
            app.session[:google_user] = user_info.body

            return user_info.body, access_token
        end
    end

    def self.revoke(app:, access_token:)
        Unirest.get "https://accounts.google.com/o/oauth2/revoke", params: { :token => access_token }
        app.session.destroy
    end
end
