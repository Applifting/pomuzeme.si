# frozen_string_literal: true

module ActiveAdmin
  module Views
    class LoadJavascript < ActiveAdmin::Component
      builder_method :javascript_for

      def build(*scripts)
        scripts.each do |js|
          script src: js
        end
      end
    end
  end
end
