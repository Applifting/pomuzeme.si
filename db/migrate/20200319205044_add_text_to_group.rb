class AddTextToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :channel_description, :text
  end
end
