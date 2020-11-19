class Session < Tableless
  phony_normalize :phone, default_country_code: 'CZ'
  phony_normalized_method :phone, default_country_code: 'CZ'

  attr_accessor :phone, :code, :redirect_to

  validates :phone, phony_plausible: true, presence: true
  validates_presence_of :volunteer, message: :not_found, if: proc { errors.messages[:phone].blank? }

  def volunteer
    @user = Volunteer.find_by phone: phone
  end

  def phone_number
    phone.present? ? phone[4..] : ''
  end
end