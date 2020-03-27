module DataImportService
  module ArrayToCsv
    OUTPUT = 'tmp/import_result.csv'.freeze

    refine Array do
      require 'csv'

      def to_csv(csv_filename = OUTPUT)
        CSV.open(csv_filename, 'wb') do |csv|
          keys = first.keys
          # header_row
          csv << keys
          each do |hash|
            csv << hash.values_at(*keys)
          end
        end
      end
    end
  end
end
