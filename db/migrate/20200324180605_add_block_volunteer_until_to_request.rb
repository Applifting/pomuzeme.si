class AddBlockVolunteerUntilToRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :block_volunteer_until, :datetime
  end
end
