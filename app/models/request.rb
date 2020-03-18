# frozen_string_literal: true

class Request < ApplicationRecord
  phony_normalize :subscriber_phone, default_country_code: 'CZ'

  belongs_to :created_by, class_name: 'User'
  belongs_to :closed_by, class_name: 'User', optional: true
  belongs_to :coordinator, class_name: 'User', optional: true
  belongs_to :organisation

  has_one :address, as: :addressable, dependent: :destroy

  enum status: Enums::RequestStatuses.to_hash, _suffix: true
  enum closed_status: Enums::RequestClosedStatuses.to_hash, _suffix: true

  validates :is_published, inclusion: { in: [true, false] }
  validates :subscriber_phone, phony_plausible: true
  validates_length_of :text, maximum: 160
  validates_presence_of :text, :required_volunteer_count, :subscriber, :subscriber_phone, :fulfillment_date, :address
  validates_associated :address

  accepts_nested_attributes_for :address

  delegate :country_code, to: :address

  scope :only_private, -> { where(is_published: false) }
  scope :only_public, -> { where(is_published: true) }

  after_initialize :initialize_defaults

  def to_s
    "#{text} ~ #{organisation}"
  end

  private

  def initialize_defaults
    self.is_published ||= false
    self.status ||= 'new'
    self.address ||= build_address
  end
end
