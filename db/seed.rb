class Seeder

	def self.seed!
		self.users!
		self.categories!
		self.issues!
		self.faq_articles!
		self.attachments!
	end

	def self.users!
		User.create(uuid: SecureRandom.uuid, name: "Joel Eriksson", given_name: "Joel", family_name: "Eriksson", avatar: "https://lh3.googleusercontent.com/-1w8EfxUcvZw/AAAAAAAAAAI/AAAAAAAAADs/BS8JXVhiD7g/photo.jpg", email: "joel.eriksson3@itggot.se", active: true, permission: :admin)
		User.create(uuid: SecureRandom.uuid, name: "Hanna Nyström", given_name: "Hanna", family_name: "Nyström", avatar: "https://camo.githubusercontent.com/a5af6e7108dcf26651439e78e22b612b96a34664/68747470733a2f2f692e696d6775722e636f6d2f376734376d33352e6a7067", active: true, email: "hanna.nystrom@itggot.se", permission: :student)
		User.create(uuid: SecureRandom.uuid, name: "Philip Lund", given_name: "Philip", family_name: "Lund", avatar: "https://camo.githubusercontent.com/00d782cc28ac06cbb2811245049fd168d3edd0aa/68747470733a2f2f692e696d6775722e636f6d2f4830344e356e502e6a7067", active: true, email: "philip.lund@itggot.se", permission: :student)
		User.create(uuid: SecureRandom.uuid, name: "Teddy Henriksson", given_name: "Teddy", family_name: "Henriksson", avatar: "https://camo.githubusercontent.com/35ffde5283c9d871d4865cab96e32fe1f1c06884/68747470733a2f2f692e696d6775722e636f6d2f33324a6f43516c2e6a7067", active: true, email: "teddy.henriksson@itggot.se", permission: :admin)
		User.create(uuid: SecureRandom.uuid, name: "Lydia Hedlund", given_name: "Lydia", family_name: "Hedlund", avatar: "https://camo.githubusercontent.com/800ceaf38d9ee0a77af0888b230347d77e1722e4/68747470733a2f2f692e696d6775722e636f6d2f326851457a59322e6a7067", active: true, email: "lydia.hedlund@itggot.se", permission: :teacher)
		User.create(uuid: SecureRandom.uuid, name: "Eddie Lindgren", given_name: "Eddie", family_name: "Lindgren", avatar: "https://camo.githubusercontent.com/60af6b29ec18c44f1cee896312d62a3e79e7359a/68747470733a2f2f692e696d6775722e636f6d2f346a6c573563502e6a7067", active: true, email: "eddie.lindgren@itggot.se", permission: :admin)
		User.create(uuid: SecureRandom.uuid, name: "Daniel Berg", given_name: "Daniel", family_name: "Berg", active: true, email: "daniel.berg1@itggot.se", avatar: "http://it-gymnasiet.se/wp-content/uploads/2014/08/berg-150x150.jpg", permission: :teacher)
	end

	def self.categories!
		@category_1 = Category.create(uuid: SecureRandom.uuid, title: "Other")
		@category_2 = Category.create(uuid: SecureRandom.uuid, title: "Windows")
		@category_3 = Category.create(uuid: SecureRandom.uuid, title: "Mac OSX")
		@category_4 = Category.create(uuid: SecureRandom.uuid, title: "Schoolsoft")
		@category_5 = Category.create(uuid: SecureRandom.uuid, title: "Adobe")
		@category_6 = Category.create(uuid: SecureRandom.uuid, title: "Microsoft Office")
		@category_7 = Category.create(uuid: SecureRandom.uuid, title: "Hardware")
	end

	def self.issues!
		issue = Issue.create(uuid: SecureRandom.uuid, title: "I'm batman", description: "Thomas Wayne: And why do we fall? So we can learn to pick ourselves up.\n\nAlfred: I'm not sure you made it loud enough, sir.\n\nJoker: I had a vision of a world without Batman. The Mob ground out a little profit and the police tried to shut them down one block at a time. And it was so boring. I've had a change of heart. I don't want Mr Reese spoiling everything but why should I have all the fun? Let's give someone else a chance. If Coleman Reese isn't dead in 60 minutes then I blow up a hospital.\n\nBane: Yes. The fire rises.\n\nBane: Do you feel in charge?\n\nBane: Speak of the devil, and he shall appear.\n\nBane: Behind you, stands a symbol of oppression. Blackgate Prison, where a thousand men have languished under the name of this man: Harvey Dent.", user_id: 1)
		Event.create(uuid: SecureRandom.uuid, type: :open, user_id: issue.user_id, issue_id: issue.id)
		issue.categories << @category_2
		issue.categories << @category_7
		issue.save

		issue = Issue.create(uuid: SecureRandom.uuid, title: "True Story", description: "Gag ipsum dolar sit amet final week creepy me gusta admire nap. In for easter homer not bad varius cat avenger grey. Simpson tank search rainbow pokeman puking rainbows female men good guy peter griffin. Forever Alone rebecca black silent hill left monday i dont get it right dolar gag cuteness overload back. Venenatis close enough superhero bra bacon megusta 140% jackie chan wodka. LOL brother crying read why bottom geek unlock joke dog. Pikachu 9000 luke thor students cereal guy aww yeah computer dad le girlfriend nyan cat in class. The avengers male elephant feel like a sir like a boss sandwich amnesia angry birds facebook y u no okay genius. Scumbag always father ipsum woman face mom captain laptop. Alcohol just star wars freddie mercury you don't say? On trolololo gasp asian too mainstream german donut hac grin note. College portfolio charlie sheen le friend homework that really? Avengers unsave party phone weekend top.\n\nAlcohol phone german le derp like a boss people pikachu tank bra i see what you did there. Geek jackie chan dad luke michelle dead dog mom search. Iron man scared super rage why dolar pizza high school brother. Father peter griffin not okay money gasp college keyboard angry birds really? Fun sister architect forever alone nyan cat puking rainbows not bad cereal guy in class steve jobs. No Bad charlie sheen superhero silent hill morbi avengers win le friend. Note pokeman simpson i dont get it nap students cat lois captain star wars. Monocle meme bear on weekend poker face y u no t-rex. Left sit i'm watching u on viverra hac essay bacon all the things. Trolololo strangers movies problem? Yao monday humor in top lose sandwich.", user_id: 2)
		Event.create(uuid: SecureRandom.uuid, type: :open, user_id: issue.user_id, issue_id: issue.id)
		issue.categories << @category_3
		issue.categories << @category_5
		issue.save

		issue = Issue.create(uuid: SecureRandom.uuid, title: "You only lorem once", description: "Yolo ipsum dolor sit amet, consectetur adipiscing elit. Ut ac suscipit leo. Carpe diem vulputate est nec commodo rutrum. Pellentesque mattis convallis nisi eu and I ain’t stoppin until the swear jar’s full. Ut rhoncus velit at mauris interdum, fringilla dictum neque rutrum. Curabitur mattis odio at erat viverra lobortis. Poppin’ bottles on the ice, tristique suscipit mauris elementum tempus. Quisque ut felis vitae elit tempor interdum viverra a est. Drop it like it’s hot, at pretium quam. In nec scelerisque purus. Nam dignissim lacus ipsum, a ullamcorper nulla pretium non. Aliquam sed enim faucibus, pulvinar felis at, vulputate augue. Ten, ten, twenties on them fifties, trick, at tempus libero fermentum id. Vivamus ut nisi dignissim, condimentum urna vel, dictum massa. Donec justo yolo, rutrum vitae dui in, dapibus tempor tellus. I do it big. Fusce ut sagittis mi.\n\nDonec accumsan consectetur faucibus. YOLO, you only live once. Donec eget semper eros. Vestibulum lobortis eros vel elementum suscipit. Nunc tempus lectus elit, et faucibus ligula dignissim nec. Phasellus in turpis porta, laoreet sapien vitae, auctor ante.  Your chick, she so thirsty, nec consequat dui imperdiet eget. In quis rhoncus sem, eu eleifend purus. Etiam sodales turpis volutpat ultricies blandit. #Swaggityswag Donec pretium tincidunt mi, id semper dolor commodo eget.\n\nDon’t trust anyone, cause you only live once. Aliquam imperdiet, ligula vehicula sodales lobortis, dui arcu ultricies libero, vitae tempor eros libero sed neque. Pop a molly, I’m sweatin’, consequat feugiat eros.  How you like your eggs, fried or fertilized? Mi ullamcorper molestie vehicula, nulla est hendrerit ante, eget tempor augue felis ut velit. Sed ut tortor nibh. Phasellus et erat a nisl molestie tempor et at mi. I’m ballin’ hard, I need a jersey on, sollicitudin eget auctor quis, aliquet vitae nulla.", closed: true, user_id: 3)
		Event.create(uuid: SecureRandom.uuid, type: :open, user_id: issue.user_id, issue_id: issue.id)
		Event.create(uuid: SecureRandom.uuid, type: :close, user_id: 4, issue_id: issue.id)
		issue.categories << @category_1
		issue.categories << @category_4
		issue.categories << @category_6
		issue.save
	end

	def self.faq_articles!
		Faq.create(uuid: SecureRandom.uuid, question: "Can’t I just fit an intruder alarm myself?", answer: "Yes, you can, but an experienced engineer will carry out an extensive survey of the site or property they are alarming to ensure that they fit the most appropriate alarm. They will also identify areas that require securing that you may not think of yourself.", user_id: 4)
		Faq.create(uuid: SecureRandom.uuid, question: "Is CCTV worth the cost?", answer: "Evidence suggests that it is a very effective deterrent against crimes being committed. It can also provide additional benefits to businesses, such as tracking footfall in a shop and ensuring staff are doing their jobs properly.", user_id: 4)
		Faq.create(uuid: SecureRandom.uuid, question: "How messy will it be to have an alarm fitted?", answer: "The process will inevitably generate some dust from drilling, but our engineers and fitters will take every possible precaution to ensure that your property is left clean by laying dust sheets on floors and nearby surfaces and objects. They will also bring their own cleaning equipment with them to tidy up after themselves afterwards. If you have our CCTV system, you can keep an eye on them to see how professional they are!", user_id: 4)
	end

	def self.attachments!
		Attachment.create(uuid: SecureRandom.uuid, file: "/uploads/123/sdjfb.png", issue_id: 1, user_id: 1)
		Attachment.create(uuid: SecureRandom.uuid, file: "/uploads/456/sdjfb.png", issue_id: 2, user_id: 2)
		Attachment.create(uuid: SecureRandom.uuid, file: "/uploads/789/sdjfb.png", issue_id: 3, user_id: 3)
	end

end
