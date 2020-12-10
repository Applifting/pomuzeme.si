require 'rails_helper'

describe Volunteer do
  let_it_be(:volunteer) { create(:volunteer, phone: '+420 666 666 666') }

  describe 'validations' do
    subject { build(:volunteer) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_uniqueness_of(:phone).case_insensitive }

    it { is_expected.not_to allow_values('foo', '1 b@example.c').for(:email) }
    it { is_expected.to allow_values('test@example.com', '').for(:email) }
  end

  describe 'associations' do
    it { should have_many(:addresses) }
    it { should have_many(:group_volunteers) }
    it { should have_many(:groups) }
    it { should have_many(:volunteer_labels) }
    it { should have_many(:labels) }
    it { should have_many(:requested_volunteers) }
    it { should have_many(:requests) }
    it { should have_many(:messages) }
  end

  describe 'scopes' do
    shared_context 'volunteers with group' do
      let(:group) { create :group }
      let(:group_applifting) { create :group_applifting }
      let(:group_exclusive_volunteer) { create :group_volunteer, group: group, is_exclusive: true}
      let!(:exclusive_volunteer) { group_exclusive_volunteer.volunteer }
      let(:another_group_exclusive_volunteer) { create :group_volunteer, group: group_applifting, is_exclusive: true}
      let!(:another_exclusive_volunteer) { another_group_exclusive_volunteer.volunteer }
      let(:group_non_exclusive_volunteer) { create :group_volunteer, group: group, is_exclusive: false}
      let!(:non_exclusive_volunteer) { group_non_exclusive_volunteer.volunteer }
    end

    describe 'with_calculated_distance' do
      let(:coordinate_target) { Geography::Point.from_coordinates longitude: 14.4615350, latitude: 50.0952747 }

      it 'adds attribute to address model instance' do
        expect(Volunteer.has_attribute?(:distance_meters)).to be false
        expect(Volunteer.with_calculated_distance(coordinate_target).first.has_attribute?(:distance_meters)).to be true
      end

      it 'calculates distance in meters' do
        scope = Volunteer.with_calculated_distance(coordinate_target).where(id: volunteer.id)
        expect(scope.first.distance_meters.to_i).to eq 492
      end
    end

    describe 'with_labels' do
      let(:label) { create :label }
      let!(:another_volunteer) { create :volunteer }

      it 'returns only volunteers with assigned labels' do
        VolunteerLabel.create! label: label, volunteer: volunteer, user: create(:user)
        expect(Volunteer.with_labels([label.id]).to_a).to include volunteer
        expect(Volunteer.with_labels([label.id]).to_a).not_to include another_volunteer
      end
    end

    describe 'available_for' do
      include_context 'volunteers with group'

      it 'returns volunteers who has exclusive access to group' do
        expect(Volunteer.available_for(group.id)).to include exclusive_volunteer
        expect(Volunteer.available_for(group.id)).not_to include another_exclusive_volunteer
      end

      it 'returns volunteers who belongs to non-exclusive access group' do
        expect(Volunteer.available_for(group.id)).to include non_exclusive_volunteer
      end

      it 'returns volunteers not assigned to any group' do
        expect(Volunteer.available_for(group.id)).to include volunteer
      end
    end

    describe 'exclusive_for' do
      include_context 'volunteers with group'

      it 'returns only volunteers exclusive to group' do
        expect(Volunteer.exclusive_for(group.id)).to include exclusive_volunteer
        expect(Volunteer.exclusive_for(group.id)).not_to include another_exclusive_volunteer
        expect(Volunteer.exclusive_for(group.id)).not_to include non_exclusive_volunteer
        expect(Volunteer.exclusive_for(group.id)).not_to include volunteer
      end
    end

    describe 'verified_by' do
      include_context 'volunteers with group'

      it 'returns volunteers verified by specific group' do
        expect(Volunteer.verified_by(group.id)).to be_empty
        group_exclusive_volunteer.active!
        expect(Volunteer.verified_by(group.id)).to include exclusive_volunteer
      end
    end

    describe 'not_recruited_by' do
      include_context 'volunteers with group'

      before do
        another_group_exclusive_volunteer.update! is_exclusive: false
      end

      it 'does not return volunteers with exclusive access to group' do
        expect(Volunteer.not_recruited_by(group.id)).not_to include exclusive_volunteer
      end

      it 'returns volunteers who belongs to non-exclusive access group which is different than passed one' do
        expect(Volunteer.not_recruited_by(group.id)).not_to include non_exclusive_volunteer
        expect(Volunteer.not_recruited_by(group.id)).to include another_exclusive_volunteer
      end

      it 'returns volunteers not assigned to any group' do
        expect(Volunteer.not_recruited_by(group.id)).to include volunteer
      end
    end

    describe 'assigned_to_request' do
      include_context 'volunteers with group'

      let(:request) { create :request }
      let!(:requested_volunteer) { create :requested_volunteer, request: request, volunteer: volunteer }

      it 'returns volunteers assigned to specific request' do
        expect(Volunteer.assigned_to_request request.id).to include volunteer
        expect(Volunteer.assigned_to_request request.id).not_to include exclusive_volunteer
        expect(Volunteer.assigned_to_request request.id).not_to include another_exclusive_volunteer
        expect(Volunteer.assigned_to_request request.id).not_to include non_exclusive_volunteer
      end
    end

    describe 'blocked' do
      include_context 'volunteers with group'

      let(:request) { create :request, block_volunteer_until: 1.week.from_now }
      let!(:requested_volunteer) { create :requested_volunteer, request: request, volunteer: volunteer }

      it 'returns only accepted volunteers blocked by some request' do
        expect(Volunteer.blocked).not_to include volunteer
        requested_volunteer.accepted!
        expect(Volunteer.blocked).to include volunteer

        expect(Volunteer.blocked).not_to include exclusive_volunteer
        expect(Volunteer.blocked).not_to include another_exclusive_volunteer
        expect(Volunteer.blocked).not_to include non_exclusive_volunteer
      end
    end

    describe 'not_blocked' do
      include_context 'volunteers with group'

      let(:request) { create :request, block_volunteer_until: 1.week.from_now }
      let!(:requested_volunteer) { create :requested_volunteer, :accepted, request: request, volunteer: volunteer }

      it 'returns only volunteers not blocked by any request' do
        expect(Volunteer.not_blocked).not_to include volunteer

        expect(Volunteer.not_blocked).to include exclusive_volunteer
        expect(Volunteer.not_blocked).to include another_exclusive_volunteer
        expect(Volunteer.not_blocked).to include non_exclusive_volunteer
      end
    end
  end

  describe '#with_existing_record' do
    it 'returns self if the record with the provided phone does not exist' do
      phone = '+420 555 555 555'
      new_volunteer = described_class.new(phone: phone)

      expect(new_volunteer.with_existing_record).to be(new_volunteer)
    end

    it 'returns the found object if the record with the provided phone exists' do
      phone = '+420 666 666 666'
      new_volunteer = described_class.new(phone: phone)

      expect(new_volunteer.with_existing_record).to eq(volunteer)
    end
  end

  describe '#verify!' do
    it 'updates confirmed_at to current time if nil' do
      travel_to Time.zone.now do
        expect { volunteer.verify! }.to change { volunteer.reload.confirmed_at }.from(nil).to(Time.zone.now)
      end
    end

    it 'does not update confirmed_at if value is present' do
      volunteer.update! confirmed_at: 1.week.ago
      expect { volunteer.verify! }.not_to change { volunteer.reload.confirmed_at }
    end
  end

  describe '#to_s' do
    it 'returns volunteers name' do
      expect(volunteer.to_s).to eq("#{volunteer.first_name} #{volunteer.last_name}")
    end
  end

  describe '#title' do
    it 'is alias for title' do
      expect(volunteer.to_s).to eq(volunteer.to_s)
    end
  end

  describe '#prepare_partner_signup' do
    let(:group)     { build :group, exclusive_volunteer_signup: true }
    let(:volunteer) { Volunteer.new }

    it 'builds the group volunteer object' do
      expect(volunteer).to receive(:build_group_volunteer).with(group)

      volunteer.prepare_partner_signup group
    end

    context 'when volunteer is new record and volunteer group has exclusive signup' do
      let(:group) { build :group, exclusive_volunteer_signup: true }

      it 'sets volunteer is_public status to false' do
        volunteer.prepare_partner_signup group

        expect(volunteer.is_public?).to be false
      end
    end

    context 'when volunteer is new record and volunteer group does not have exclusive signup' do
      let(:group)     { build :group, exclusive_volunteer_signup: false }
      let(:volunteer) { Volunteer.new(is_public: true) }

      it 'it leaves the default is_public status unchanged' do
        volunteer.prepare_partner_signup group

        expect(volunteer.is_public?).to be true
      end
    end

    context 'when volunteer is not new record and volunteer group has exclusive signup' do
      let(:group)     { build :group, exclusive_volunteer_signup: true }
      let(:volunteer) { create :volunteer, is_public: true }

      it 'it leaves the is_public status unchanged' do
        volunteer.prepare_partner_signup group

        expect(volunteer.is_public?).to be true
      end
    end
  end

  describe '#process_manual_registration' do
    let(:volunteer) { create :volunteer }
    let(:user)      { create :user, :with_organisation_group }

    it 'sets the volunteers phone number as confirmed' do
      expect(volunteer.confirmed_at).to be_nil

      volunteer.process_manual_registration user
      expect(volunteer.confirmed_at).to be_instance_of(ActiveSupport::TimeWithZone)
    end

    it 'creates onboarding for the volunteer' do
      volunteer.process_manual_registration user

      expect(volunteer.group_volunteers.count).to eq 1
      expect(volunteer.group_volunteers.first.recruitment_status).to eq 'onboarding'
      expect(volunteer.group_volunteers.first.is_exclusive).to be true
      expect(volunteer.group_volunteers.first.coordinator).to eq user
      expect(volunteer.group_volunteers.first.source).to eq 'manual'
    end
  end
end
