Ransack.configure do |config|
  config.add_predicate 'in_all',
                       # What non-compound ARel predicate will it use? (eq, matches, etc)
                       arel_predicate: 'in',
                       # Format incoming values as you see fit. (Default: Don't do formatting)
                       formatter: proc { |val| val == 'nil' ? nil : val },
                       # Validate a value. An "invalid" value won't be used in a search.
                       # Below is default.
                       # :validator => proc {|v| v.present?},
                       validator: proc { |val| val.present? && !val.blank? },
                       # Should compounds be created? Will use the compound (any/all) version
                       # of the arel_predicate to create a corresponding any/all version of
                       # your predicate. (Default: true)
                       compounds: true,
                       # Lets us force per item array handling in the valiator and formatter
                       wants_array: false
  # Force a specific column type for type-casting of supplied values.
  # (Default: use type from DB column)
  # :type => :string
end
