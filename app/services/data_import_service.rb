module DataImportService
  def self.call(filename, group)
    Importer.new(filename, group).call
  end

  def self.cleanup(group, org_names)
    Volunteer.joins(:group_volunteers).where(group_volunteers: { group_id: group.id }).destroy_all
    orgs = Organisation.where(name: org_names)
    Request.where(organisation_id: orgs.pluck(:id)).destroy_all
    orgs.destroy_all
    Label.where(group_id: group.id).destroy_all
  end
end

# TODOs
# budou jedna organizace
# nefunguje opakovaná adres
# upravit adresu exklusivního dobrovolní
# find existing organisations, coordinators, labels, requests
# hledat poptávku podle příjemce / zobrazit příjemce v seznamu
# organizace defaultní (1)
# seřadit štítky ve filtrech abecedně
# abecedně seřadit štítky ve filtru
