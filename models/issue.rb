class Issue
	include DataMapper::Resource

	property :id, Serial
	property :uuid, String, required: true, unique: true
	property :title, String, required: true
	property :description, Text, required: true
	property :custom_email, String, format: :email_address
	property :solved, Boolean, default: false
	property :created_at, EpochTime
	property :updated_at, EpochTime

	belongs_to :user
	has n, :attachments
	has n, :categories, :through => Resource

	def self.report(app:, user:, params:)
		description = ""
		params[:description].squeeze("\n").split("\n").each do |line|
			description << "#{line}\n\n"
		end
		issue = Issue.create(uuid: SecureRandom.uuid, title: params[:title], description: description, user_id: user.id)
        if params[:category]
            params[:category].each do |category|
                issue.categories << Category.first(uuid: category)
            end
            issue.save
        end
        return issue
	end

	def self.delete(app:, user:, params:)
		unless user.permission_admin
			return false
		end

		issue = Issue.first(uuid: params[:issue])
		unless issue
			return throw_error(app: self, code: 404, message: "not found")
		end

		if issue.attachments
			for attachment in issue.attachments
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

	def self.mark_solved(app:, user:, params:)
		issue = Issue.first(uuid: params[:issue])
		unless issue
			return throw_error(app: self, code: 404, message: "not found")
		end

		if params[:solved] == "y"
			issue.update(solved: true)
		elsif params[:solved] == "n"
			issue.update(solved: false)
		end
	end
end
