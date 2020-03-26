module DataImportService
  module Utils
    def transaction_wrapper
      ActiveRecord::Base.connection.transaction do
        yield
      rescue StandardError => e
        puts e
        puts e.backtrace[0..20]
        raise ActiveRecord::Rollback if @row_output.keys.any? { |k| k.to_s.start_with? 'error' }
      ensure
        @output << @row_output
      end
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
