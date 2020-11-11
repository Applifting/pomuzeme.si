# typed: false
# frozen_string_literal: true

module ViewHelper
  include ViewHelpers

  def tooltip(text)
    h.content_tag :img, nil, src: asset_pack_path('media/images/tooltip.svg'),
                             class: "tooltipped",
                             'data-position' => 'top',
                             'data-tooltip' => text
  end
end