module DataImportService
  def self.call(filename, group)
    Importer.new(filename, group).call
  end
end
