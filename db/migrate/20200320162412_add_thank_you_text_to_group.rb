class AddThankYouTextToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :thank_you, :text
  end
end
