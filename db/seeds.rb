return unless Rails.env.development?

# create super admin
SeedHelper.create_super_admin email: 'admin@example.com', password: 'password'

# seed organisations
organisation1 = SeedHelper.create_organisation name: 'Oblastni charita',
                                               abbrevation: 'OCH',
                                               contact_person: 'reditelka pobocky',
                                               contact_person_phone: '+420222444333',
                                               contact_person_email: 'area@charita.cz'

organisation2 = SeedHelper.create_organisation name: 'Spolek dobrovolniku',
                                               abbrevation: 'SDO',
                                               contact_person: 'pan Novak',
                                               contact_person_phone: '+420222444322',
                                               contact_person_email: 'novak@gmail.com'

SeedHelper.create_coordinator(email: 'coordinator@example.com', password: 'password', organisation: organisation1)
SeedHelper.create_coordinator(email: 'coordinator2@example.com', password: 'password', organisation: organisation2)


# Create sample volunteers
SeedHelper.create_volunteer(first_name: 'Marie', last_name: 'Laskava', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420777666555', email: 'marie@laskava.cz')
SeedHelper.create_volunteer(first_name: 'Teodor', last_name: 'Dobry', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420455888333', email: 'teo@dobry.cz')
SeedHelper.create_volunteer(first_name: 'Petra', last_name: 'Mala', zipcode: '77900', city: 'Olomouc', street: '17. listopadu 1192', phone: '+420603225444', email: 'petra@mala.cz')
