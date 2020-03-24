class AddressesStreetNumberNull < ActiveRecord::Migration[6.0]
  def change
    change_column :addresses, :street_number, :string, null: true
  end
end
