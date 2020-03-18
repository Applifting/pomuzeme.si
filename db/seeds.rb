# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create sample volunteers
SeedHelper.create_volunteer(first_name: 'Marie', last_name: 'Laskava', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420777666555', email: 'marie@laskava.cz')
SeedHelper.create_volunteer(first_name: 'Teodor', last_name: 'Dobry', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420455888333', email: 'teo@dobry.cz')
SeedHelper.create_volunteer(first_name: 'Petra', last_name: 'Mala', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420603225444', email: 'petra@mala.cz')

(1..50).each do |i|
  identifier = '%03d' % i
  SeedHelper.create_volunteer(first_name: 'Volunteer', last_name: identifier, zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420603225' + identifier, email: 'volunteer@007.cz')
end