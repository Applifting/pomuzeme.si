return unless Rails.env.development?

# create super admin
admin = SeedHelper.create_super_admin email: 'admin@example.com', password: 'password', first_name: 'Iva', last_name: 'Červená'

# seed groups and organisations
organisation1 = SeedHelper.create_organisation name: 'Oblastni charita',
                                               abbreviation: 'OBCH',
                                               contact_person: 'reditelka pobocky',
                                               contact_person_phone: '+420222444333',
                                               contact_person_email: 'area@charita.cz'

organisation2 = SeedHelper.create_organisation name: 'Spolek dobrovolniku',
                                               abbreviation: 'SPOL',
                                               contact_person: 'pan Novak',
                                               contact_person_phone: '+420222444322',
                                               contact_person_email: 'novak@gmail.com'

organisation3 = SeedHelper.create_organisation name: 'Diakonie',
                                               abbreviation: 'DIAK',
                                               contact_person: 'pan Novak',
                                               contact_person_phone: '+420222444323',
                                               contact_person_email: 'novak@gmail.com'

SeedHelper.create_group organisation: organisation1, name: 'Oblastni charita GRP', slug: 'oblastni-charita'
SeedHelper.create_group organisation: organisation2, name: 'Spolek dobrovolniku GRP', slug: 'spolek-dobrovolniku'
SeedHelper.create_group organisation: organisation3,
                        name: 'Diakonie',
                        slug: 'diakonie',
                        channel_description: "Už 30 let pomáháme
                                               dětem a dospělým, seniorům i lidem v různých životních krizích.
                                               Jsme jeden z nejvýznamnějších poskytovatelů sociálních služeb v ČR a jednička ve speciálním školství."

coordinator1 = SeedHelper.create_coordinator(email: 'coordinator@example.com', password: 'password', organisation: organisation1, first_name: 'Pavel', last_name: 'Pomahac')
coordinator2 = SeedHelper.create_coordinator(email: 'coordinator2@example.com', password: 'password', organisation: organisation2, first_name: 'Josef', last_name: 'Novak')
coordinator3 = SeedHelper.create_coordinator(email: 'coordinator3@example.com', password: 'password', organisation: organisation1, first_name: 'Josef', last_name: 'Novak')
admin.grant :coordinator, organisation1

# Create sample volunteers
SeedHelper.create_volunteer(first_name: 'Marie', last_name: 'Laskava', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420777666555', email: 'marie@laskava.cz')
SeedHelper.create_volunteer(first_name: 'Teodor', last_name: 'Dobry', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420455888333', email: 'teo@dobry.cz')
SeedHelper.create_volunteer(first_name: 'Petra', last_name: 'Mala', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420603225444', email: 'petra@mala.cz')

(1..50).each do |i|
  identifier = '%03d' % i
  SeedHelper.create_volunteer(first_name: 'Volunteer', last_name: identifier, zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420603225' + identifier, email: 'volunteer@007.cz')
end

SeedHelper.create_request(organisation: organisation1, coordinator: coordinator1, text: 'Potřebujeme 5 dobrovolníků', required_volunteer_count: 5, subscriber: 'Subscriber', subscriber_phone: '+420 555 555 555', creator: User.first, state_last_updated_at: DateTime.now)
SeedHelper.create_request(organisation: organisation1, coordinator: coordinator1, text: 'Potřebujeme 10 dobrovolníků', required_volunteer_count: 10, subscriber: 'Subscriber', subscriber_phone: '+420 555 555 555', creator: User.first, state_last_updated_at: DateTime.now, state: :pending_confirmation)
SeedHelper.create_request(organisation: organisation1, coordinator: coordinator1, text: 'Potřebujeme 12 dobrovolníků', required_volunteer_count: 12, subscriber: 'Subscriber', subscriber_phone: '+420 555 555 555', creator: User.first, state_last_updated_at: DateTime.now, state: :pending_confirmation)
SeedHelper.create_request(organisation: organisation2, text: 'Potřebujeme 5 dobrovolníků', required_volunteer_count: 5, subscriber: 'Subscriber', subscriber_phone: '+420 555 555 555', creator: User.first, state_last_updated_at: DateTime.now)
SeedHelper.create_request(organisation: organisation1, coordinator: coordinator3, text: 'Potřebujeme 8 dobrovolníků', required_volunteer_count: 8, subscriber: 'Subscriber', subscriber_phone: '+420 555 555 555', creator: User.first, state_last_updated_at: DateTime.now)
