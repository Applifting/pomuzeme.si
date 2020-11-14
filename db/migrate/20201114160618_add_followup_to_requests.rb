class AddFollowupToRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :requests, :follow_up_after, :timestamp
  end
end
