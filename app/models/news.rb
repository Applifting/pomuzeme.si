class News < ApplicationRecord
  # Attributes
  enum publication_type: { news: 1, from_media: 2 }

  # Validations
  validates_presence_of :publication_type, :title

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :published, -> { where('created_at < ?', Time.zone.now) }

  # Hooks
  after_commit :invalidate_news_cache

  def self.cached_recent_news(count = 5)
    Rails.cache.fetch :news do
      News.news.recent.published.limit(count)
    end
  end

  def self.cached_recent_from_media(count = 5)
    Rails.cache.fetch :from_media do
      News.from_media.recent.published.limit(count)
    end
  end

  private

  def invalidate_news_cache
    Rails.cache.delete :news
    Rails.cache.delete :password_confirmation
  end
end
