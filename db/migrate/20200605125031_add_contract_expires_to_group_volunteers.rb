class AddContractExpiresToGroupVolunteers < ActiveRecord::Migration[6.0]
  def change
    add_column :group_volunteers, :contract_expires, :date
  end
end
