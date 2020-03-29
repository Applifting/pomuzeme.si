# frozen_string_literal: true

class MessageDecorator < ApplicationDecorator
  delegate_all

  def sent_by_css(prefix_css = nil)
    [prefix_css, (direction == :outgoing ? :coordinator : :volunteer)].compact.join(' ')
  end

  def read_status_css
    :unread
    # read ? '' : :unread
  end
end
