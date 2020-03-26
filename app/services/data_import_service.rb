module DataImportService
  def self.call(filename, group)
    Importer.new(filename, group).call
  end
end

# TODOs
# upload csv
# chunk
# download result
# find existing coordinators, labels, requests
