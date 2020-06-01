module DataImportService
  module ModelHelpers
    def find_or_create_by(klass, attribute, value)
      return if value.blank? || attribute.blank?

      creator = (klass.to_s.underscore + '_creator').to_sym

      @cache[klass.to_s][attribute][value].presence || (@cache[klass.to_s][attribute][value] = send(creator, attribute, value))
    end

    def find_or_build_by(klass, name)
      return unless name

      creator = (klass.to_s.underscore + '_builder').to_sym

      @cache[klass.to_s][name] ||= send(creator, name)
    end

    def append_error(model)
      erred_model = model.class.to_s.underscore
      @row_output = @row_output.merge("error_#{erred_model}" => model.errors.messages)
    end

    def save_model(instance)
      return unless instance

      if instance.valid?
        instance.save
        block_given? ? yield(instance) : instance
      else
        append_error(instance)
        block_given? ? yield(nil) : nil
      end
    end

    def build_instance(klass, item)
      klass_prefix = klass.to_s.underscore + '_'

      data = item.select { |key| key.start_with? klass_prefix }
                 .transform_keys { |key| key.gsub(klass_prefix, '') }

      error_catcher(klass) do
        block_given? ? klass.new(yield(data)) : klass.new(data)
      end
    end

    def error_catcher(object)
      yield
    rescue ArgumentError => e
      model = if object.is_a? Class
                klass.new.tap { |instance| instance.errors.add(:base, e.message) }
              else
                object
              end
      append_error(model)
      raise e
    end
  end
end
