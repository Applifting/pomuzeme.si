# frozen_string_literal: true

require 'rails_helper'

RSpec.describe News, type: :model do
  context 'validations' do
    subject { create(:news) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:publication_type) }
  end

  context 'enums' do
    it { should define_enum_for(:publication_type).with_values(news: 1, from_media: 2) }
  end

  context 'scopes' do
    context '.recent' do
      let!(:news_1) { create :news, created_at: 5.seconds.ago }
      let!(:news_2) { create :news, created_at: 1.seconds.ago }
      let!(:news_3) { create :news, created_at: 3.seconds.ago }

      it 'returns news sorted by newest first' do
        expect(News.recent.to_a).to eq([news_2, news_3, news_1])
      end
    end

    context '.published' do
      let(:travel_time) { Time.zone.local(2020, 0o5, 0o5, 20, 0o0, 0o0) }

      it 'returns records created before current time' do
        news = create :news, created_at: 1.second.ago
        expect(News.published).to include(news)
      end

      it 'returns records with created_at time in future' do
        news = create :news, created_at: 1.second.from_now
        expect(News.published).not_to include(news)
      end
    end
  end
end
