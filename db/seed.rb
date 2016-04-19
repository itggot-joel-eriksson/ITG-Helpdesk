class Seeder

	def self.seed!
		self.categories!
		self.issues!
		self.faq_articles!
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
		FAQ.create question: "Hej", answer: "Då-re", user_id: 1
	end

end
