module DataImportService
  module Utils
    def transaction_wrapper
      ActiveRecord::Base.connection.transaction do
        yield
      rescue StandardError => e
        puts e
        puts e.backtrace[0..20]
        Raven.capture_exception e
        raise ActiveRecord::Rollback
      ensure
        @output << @row_output if error_present?
      end
    end

    def error_present?
      @row_output.any? { |k, v| k.start_with?('error') && v.present? }
    end

    def read_lines
      @csv = CSV.open(@filename, headers: true)
      loop do
        line = @csv.readline.to_h
        line.present? ? @raw_lines << line : break
      end
    rescue StandardError => e
      puts 'File not found'
      puts e
    end
  end
end
