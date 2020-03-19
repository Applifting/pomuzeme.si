class AddProviderToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :geo_provider, :string

    reversible do |dir|
      dir.up do
        Address.reset_column_information
        Address.update_all geo_provider: 'cadstudio'
      end
    end
  end
end
