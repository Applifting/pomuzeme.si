# typed: true
# frozen_string_literal: true

module ActiveAdmin
  module Views
    class ModalWindowComponent < ActiveAdmin::Component
      builder_method :modal_window

      def build(*)
        div class: 'modal', 'data-modal': true do
          div class: 'content-wrapper' do
            button class: 'close'
            div class: 'content'
          end
        end
      end
    end
  end
end
