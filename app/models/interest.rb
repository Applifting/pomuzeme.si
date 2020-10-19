class Interest < ApplicationRecord
  before_validation :generate_code

  validates_presence_of :name, :code
  validates_uniqueness_of :name, :code

  private

  def generate_code
    return if code.present?

    self.code = I18n.transliterate(name).split(' ').map(&:downcase).join('_')
  end
end
