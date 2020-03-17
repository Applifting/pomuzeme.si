# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  belongs_to :closed_by, class_name: 'User', optional: true
  belongs_to :coordinator, class_name: 'User', optional: true
  belongs_to :organisation

  has_one :address, as: :addressable, dependent: :destroy

  enum status: { new: 'new',
                 searching_capacity: 'searching_capacity',
                 pending_confirmation: 'pending_confirmation',
                 help_coordinated: 'help_coordinated',
                 closed: 'closed' }, _suffix: true
  enum closed_status: { fulfilled: 'fulfilled',
                        failed: 'failed',
                        irrelevant: 'irrelevant' }, _suffix: true

  validates :is_published, inclusion: { in: [true, false] }
  validates_length_of :text, maximum: 160
  validates_presence_of :text, :required_volunteer_count, :subscriber, :subscriber_phone, :fulfillment_date
  validates_associated :address

  accepts_nested_attributes_for :address

  before_validation :prepare_default

  private

  def prepare_default
    self.is_published ||= false
    self.status ||= 'new'
  end
end
