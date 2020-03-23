class DataImportService
  attr_accessor :raw_lines

  def initialize(filename)
    @csv = CSV.open(filename, headers: true)
    @raw_lines = []

    read_lines
  rescue Errno::ENOENT
    puts 'File not found'
  end

  def create_model
    raw_lines.map do |line|
      volunteer = create_volunteer(line).save
    end
  end

  def create_volunteer(line)
    address = nil
    volunteer = create_instance(Volunteer, line) do |data|
      address = Address.new_from_string(data['address'])
      data.except('address')
    end
    volunteer.tap { |v| v.addresses << address }
  end

  def create_instance(klass, item)
    klass_prefix = klass.to_s.underscore + '_'

    data = item.select { |key| key.start_with? klass_prefix }
               .transform_keys { |key| key.gsub(klass_prefix, '') }

    block_given? ? klass.new(yield(data)) : klass.new(data)
  end

  def read_lines
    loop do
      line = @csv.readline.to_h
      line.present? ? @raw_lines << line : break
    end
  end
end
