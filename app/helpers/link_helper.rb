# typed: false
# frozen_string_literal: true

module LinkHelper
  def modal_link(title = '', path, **options)
    link_to title, path, options.merge(remote: true, 'data-modal-trigger': true)
  end
end