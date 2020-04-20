class AddLongDescriptionToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :long_text, :string
  end
end
