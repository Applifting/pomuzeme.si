module DataImportService
  class Importer
    include Creators
    include Builders
    include Utils
    include ModelHelpers

    using DataImportService::ArrayToCsv

    attr_accessor :raw_lines

    def initialize(filename, organisation_group, output_file = DataImportService::ArrayToCsv::OUTPUT)
      @filename    = filename
      @output_file = output_file
      @group       = organisation_group
      @volunteer   = nil
      @raw_lines   = []
      @output      = []
      @row_output  = nil
      @cache       = Hash.new({})

      check_inputs
    end

    def call
      read_lines
      import_data

      @output.to_csv(@output_file) if @output.present?
    end

    def import_data
      raw_lines.map do |row|
        transaction_wrapper do
          @row = row
          @row_output = row.dup.merge(error_headers)

          save_model(volunteer_builder) do |volunteer|
            @volunteer = volunteer
            save_model group_volunteer_builder

            request ||= find_or_create_by(Request, row['request_text'])
            requested_volunteer_creator(request) if request

            volunteer_labels_creator
          end
        end
      end
    end

    private

    def check_inputs
      raise TypeError unless @group.is_a? Group
    end

    def error_headers
      {
        'error_volunteer' => nil,
        'error_group_volunteer' => nil,
        'error_request' => nil,
        'error_label' => nil
      }
    end
  end
end
