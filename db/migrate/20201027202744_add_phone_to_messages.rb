class AddPhoneToMessages < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :phone, :string, index: true
  end
end
