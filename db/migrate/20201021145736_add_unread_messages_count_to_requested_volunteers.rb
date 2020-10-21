class AddUnreadMessagesCountToRequestedVolunteers < ActiveRecord::Migration[6.0]
  def change
    add_column :requested_volunteers, :unread_incoming_messages_count, :integer, null: false, default: 0

    reversible do |dir|
      dir.up do
        RequestedVolunteer.all.each { |rv| rv.update unread_incoming_messages_count: rv.unread_incoming_messages.count }
      end
    end
  end
end
