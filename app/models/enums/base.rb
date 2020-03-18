class Enums::Base
  VALUES = [].freeze

  def self.to_hash
    Hash[self::VALUES.collect { |item| [item, item] }]
  end
end
