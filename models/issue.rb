class Issue
	include DataMapper::Resource

	property :id, Serial
	property :uuid, String, required: true, unique: true
	property :title, String, required: true
	property :description, Text, required: true
	property :custom_email, String, format: :email_address
	property :notifications, Boolean, default: true
	property :closed, Boolean, default: false
	property :created_at, EpochTime
	property :updated_at, EpochTime

	belongs_to :user
	has n, :attachments
	has n, :categories, through: Resource
	has n, :events

	def self.report(app:, user:, params:)
		description = ""
		params[:description].squeeze("\n").split("\n").each do |line|
			description << "#{line}\n\n"
		end
		if params[:custom_email]
			issue = Issue.create(uuid: SecureRandom.uuid, title: params[:title], description: description, custom_email: params[:custom_email], notifications: params[:notifications] == "on", user_id: user.id)
		else
			issue = Issue.create(uuid: SecureRandom.uuid, title: params[:title], description: description, notifications: params[:notifications] == "on", user_id: user.id)
		end

		Event.create(uuid: SecureRandom.uuid, type: :open, user_id: user.id, issue_id: issue.id)

        if params[:category]
            params[:category].each do |category|
                issue.categories << Category.first(uuid: category)
            end
            issue.save
        end
        return issue
	end

	def self.delete(app:, user:, params:)
		return throw_error(app: app, code: 403, message: "forbidden") unless user.permission == :admin

		issue = Issue.first(uuid: params[:issue])
		return throw_error(app: app, code: 404, message: "not found") unless issue

		if issue.attachments
			issue.attachments.each do |attachment|
				file = "uploads/#{user.uuid}/#{File.basename(attachment.file)}"
				if File.exist?(file)
					File.unlink(file)
				end
			end
		end
		issue.attachments.destroy
		issue.category_issues.destroy
		issue.destroy!
	end

	def self.delete_all(app:, user:, user_id:)
		return throw_error(app: app, code: 403, message: "forbidden") unless user.permission == :admin

		issues = Issue.all(user_id: user_id)
		return throw_error(app: app, code: 404, message: "not found") unless issues

		issues.each do |issue|
			if issue.attachments
				issue.attachments.each do |attachment|
					file = "uploads/#{user.uuid}/#{File.basename(attachment.file)}"
					if File.exist?(file)
						File.unlink(file)
					end
				end
			end
			issue.attachments.destroy!
			issue.category_issues.destroy!
			issue.destroy!
		end
	end

	def self.close(app:, user:, uuid:)
		issue = Issue.first(uuid: uuid)
		return throw_error(app: app, code: 404, message: "not found") unless issue

		issue.update(closed: true)
		Event.create(uuid: SecureRandom.uuid, type: :close, user_id: user.id, issue_id: issue.id)
		app.flash[:tab] = :closed
	end

	def self.open(app:, user:, uuid:)
		issue = Issue.first(uuid: uuid)
		return throw_error(app: app, code: 404, message: "not found") unless issue

		issue.update(closed: false)
		Event.create(uuid: SecureRandom.uuid, type: :reopen, user_id: user.id, issue_id: issue.id)
		app.flash[:tab] = :open
	end
end
