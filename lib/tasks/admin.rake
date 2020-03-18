namespace :admin do
  task :create_super_admin, [:first_name, :last_name, :email, :password] => [ :environment ] do |t, args|
    user = User.new first_name: args[:first_name],
                    last_name: args[:last_name],
                    email: args[:email],
                    password: args[:password],
                    password_confirmation: args[:password]
    unless user.valid?
      puts 'Cannot create user'
      user.errors.full_messages.each { |error_message| puts error_message }
      return
    end
    ActiveRecord::Base.transaction do
      user.save!
      user.add_role :super_admin
    end
  end
end
