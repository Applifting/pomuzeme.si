class OrganisationSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :abbreviation,
             :business_id_number,
             :contact_person,
             :contact_person_phone,
             :contact_person_email
end