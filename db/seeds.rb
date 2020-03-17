return unless Rails.env.development?

# create super admin
SeedHelper.create_super_admin email: 'admin@example.com', password: 'password', first_name: 'Awesome', last_name: 'Admin'

# seed organisations
organisation1 = SeedHelper.create_organisation name: 'Oblastni charita',
                                               abbreviation: 'OBCH',
                                               contact_person: 'reditelka pobocky',
                                               contact_person_phone: '+420222444333',
                                               contact_person_email: 'area@charita.cz'

organisation2 = SeedHelper.create_organisation name: 'Spolek dobrovolniku',
                                               abbreviation: 'SPDO',
                                               contact_person: 'pan Novak',
                                               contact_person_phone: '+420222444322',
                                               contact_person_email: 'novak@gmail.com'

organisation3 = SeedHelper.create_organisation name: 'Spolek dobrovolniku 2',
                                               abbreviation: 'SPDO',
                                               contact_person: 'pan Novak',
                                               contact_person_phone: '+420222444323',
                                               contact_person_email: 'novak@gmail.com'

coordinator1 = SeedHelper.create_coordinator(email: 'coordinator@example.com', password: 'password', organisation: organisation1, first_name: 'Pavel', last_name: 'Pomahac')
SeedHelper.create_coordinator(email: 'coordinator2@example.com', password: 'password', organisation: organisation2, first_name: 'Josef', last_name: 'Novak')
SeedHelper.create_coordinator(email: 'coordinator3@example.com', password: 'password', organisation: organisation1, first_name: 'Josef', last_name: 'Novak')


# Create sample volunteers
SeedHelper.create_volunteer(first_name: 'Marie', last_name: 'Laskava', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420777666555', email: 'marie@laskava.cz')
SeedHelper.create_volunteer(first_name: 'Teodor', last_name: 'Dobry', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420455888333', email: 'teo@dobry.cz')
SeedHelper.create_volunteer(first_name: 'Petra', last_name: 'Mala', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420603225444', email: 'petra@mala.cz')

(1..50).each do |i|
  identifier = '%03d' % i
  SeedHelper.create_volunteer(first_name: 'Volunteer', last_name: identifier, zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420603225' + identifier, email: 'volunteer@007.cz')
end

# seed requests
SeedHelper.create_request(text: 'Humble request', required_volunteer_count: 2, subscriber: 'Jiri Novak', subscriber_phone: '+420777666555', created_by: coordinator1, organisation: organisation1,
                          fulfillment_date: 10.days.from_now, street: 'Street', street_number: '10', city: 'City', city_part: 'City Part', geo_coord_x: 80, geo_coord_y: 80, postal_code: '55002',
                          country_code: 'CZ')
SeedHelper.create_request(text: 'Public request', required_volunteer_count: 2, subscriber: 'Jiri Novak', subscriber_phone: '+420777666555', created_by: coordinator1, organisation: organisation1,
                          fulfillment_date: 10.days.from_now, street: 'Street', street_number: '10', city: 'City', city_part: 'City Part', geo_coord_x: 80, geo_coord_y: 80, postal_code: '55002',
                          country_code: 'CZ', is_published: true)
SeedHelper.create_request(text: 'Closed request', required_volunteer_count: 2, subscriber: 'Jiri Novak', subscriber_phone: '+420777666555', created_by: coordinator1, organisation: organisation1,
                          fulfillment_date: 10.days.from_now, street: 'Street', street_number: '10', city: 'City', city_part: 'City Part', geo_coord_x: 80, geo_coord_y: 80, postal_code: '55002',
                          country_code: 'CZ', status: 'closed', closed_note: 'Done', closed_at: 1.day.ago, closed_status: 'fulfilled', closed_by: coordinator1)
