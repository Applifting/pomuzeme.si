module ActiveAdmin
  module Inputs
    class AddressSearchInput < ::Formtastic::Inputs::StringInput # Add filter module wrapper
      include ActiveAdmin::Inputs::Filters::Base

      def to_html
        input_wrapping do
          [label_html,
           builder.text_field('id', input_html_options)].join("\n").html_safe
        end
      end

      def input_html_options
        { id: 'address_search_input_text', class: 'geocomplete_filter' }
      end
    end
  end
end
