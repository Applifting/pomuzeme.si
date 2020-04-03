class AddTypeToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :message_type, :integer, null: false, default: 1
  end
end
