class Seeder

	def self.seed!
		self.categories!
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
	
end