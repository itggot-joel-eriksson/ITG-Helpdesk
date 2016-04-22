class Seeder

	def self.seed!
		self.users!
		self.categories!
		self.issues!
		self.faq_articles!
		self.uploads!
	end

	def self.users!
		User.create email: "hanna.nystrom@itggot.se"
		User.create email: "philip.lund@itggot.se"
		User.create email: "teddy.henriksson@itggot.se"
		User.create email: "lydia.hedlund@itggot.se"
		User.create email: "eddie.lindgren@itggot.se"
	end

	def self.categories!
		Category.create title: "Annat"
		Category.create title: "Windows"
		Category.create title: "Mac OSX"
		Category.create title: "Schoolsoft"
		Category.create title: "Adobe"
		Category.create title: "Microsoft Office"
		Category.create title: "Hårdvara"
	end

	def self.issues!
		Issue.create title: "Trasig skärm", description: "Skärmen på datorn har fått en spricka i sig och fungerar inte som den skall.", user_id: 1
		Issue.create title: "Uppdatera till Windows 10", description: "Datorn kör för närvarande Windows 7 men jag skulle vilja uppdatera till Windows 10.", user_id: 2
	end

	def self.faq_articles!
		Faq.create question: "Hej", answer: "Då-re", user_id: 1
	end

	def self.uploads!
		Upload.create
		Upload.create
		Upload.create
	end

end
