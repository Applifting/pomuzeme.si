class AddIsPublicToRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :is_public, :boolean, default: false
  end
end
