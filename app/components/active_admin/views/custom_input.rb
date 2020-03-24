module ActiveAdmin
  module Views
    class CustomInput < ActiveAdmin::Component
      builder_method :custom_input

      def build(name, options = {})
        if options[:type] == :hidden
          input(extract_options(name, options))
        elsif options[:type] == :input
          input(extract_options(name, options))
        else
          li class: 'input stringish optional', id: li_id(name) do
            label for: default_id(name), class: 'label' do
              label_text(name, options)
            end
            input(extract_options(name, options))
          end
        end
      end

      private

      def label_text(name, options)
        options[:label] ? normalize_name(options[:label]) : normalize_name(name)
      end

      def normalize_name(name)
        name.to_s.split('_').join(' ').camelize
      end

      def li_id(name)
        [resource.model_name.element, name.to_s, 'input'].join('_')
      end

      def default_id(name)
        [resource.model_name.element, name.to_s].join('_')
      end

      def default_name(name)
        "#{resource.model_name.element}[#{name}]"
      end

      def extract_options(name, options)
        base = {
            type:  options[:type] || 'text',
            id:    options[:id] || default_id(name),
            name:  options[:name] || default_name(name),
            class: options[:class]
        }
        options.except(:id, :class).merge(base)
      end
    end
  end
end
