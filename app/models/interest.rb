class Interest < ApplicationRecord
  # Hooks
  before_validation :generate_code

  # Validations
  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code

  # Scopes
  scope :alphabetically, -> { order(:name) }

  private

  def generate_code
    return if code.present?

    self.code = I18n.transliterate(name).split(' ').map(&:downcase).join('_')
  end
end
