# typed: false
# frozen_string_literal: true

module AddressForm
  def self.build(address_params)
    data = Builder.build(address_params)
    Form.decorate data.address
  end

  class Form < ::AddressDecorator
    delegate_all
    decorates :address

    def persisted?
      return true
      object.persisted?
    end

    def save
      return if object.nil?

      object.save
    end
  end
end
