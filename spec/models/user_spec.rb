require 'rails_helper'

describe User do
  describe 'validations' do
    subject { described_class.new }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end
end
