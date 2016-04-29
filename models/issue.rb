class Issue
	include DataMapper::Resource

	property :id, Serial
	property :uuid, String, required: true, unique: true
	property :title, String, required: true
	property :description, Text, required: true
	property :created_at, EpochTime

	belongs_to :user
	has n, :attachments
	has n, :categories, :through => Resource

	def self.report(app:, user:, params:)
		issue = Issue.create(uuid: SecureRandom.uuid, title: params[:title], description: params[:description], user_id: user.id)
        if params[:category]
            for category in params[:category] do
                issue.categories << Category.first(uuid: category)
            end
            issue.save
        end
        return issue
	end

	def self.delete(app:, user:, params:)
		issue = Issue.first(uuid: params[:issue])
		unless issue
			status 404
			slim :error
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
        app.redirect "/issues"
	end
end
