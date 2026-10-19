user = User.find_or_initialize_by(email: 'dev@teamtable.local')
user.name = 'Dev User'
user.password = 'password'
user.password_confirmation = 'password'
user.skip_confirmation!
user.save!
