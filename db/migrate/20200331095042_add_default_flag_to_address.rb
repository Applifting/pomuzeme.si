class AddDefaultFlagToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :default, :boolean

    Address.reset_column_information

    reversible do |dir|
      dir.up do
        Address.where('addresses.id IN (SELECT MAX(addresses.id) from addresses GROUP BY addressable_id)')
               .order('addresses.created_at DESC')
               .update_all(default: true)
      end
    end

    add_index :addresses, %i[addressable_id addressable_type default], where: 'addresses.default=true', unique: true, name: 'addresses_only_one_default'
  end
end
