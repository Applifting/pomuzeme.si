module Cacheable
  include ActiveSupport::Concern

  CACHE_TIMEOUT = 5 # minutes
  CACHED_METHOD_PREFIX = 'cached_'.freeze

  def cache_output(key, expires_in: nil)
    Rails.cache.fetch "#{cache_key_with_version}::#{key}", expires_in: (expires_in || CACHE_TIMEOUT).minutes do
      yield self
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?(CACHED_METHOD_PREFIX) || super
  end

  private

  def method_missing(m, *args)
    method_name = m.to_s.split(CACHED_METHOD_PREFIX).last
    return super unless method_name.present? && respond_to?(method_name)

    cache_output(method_name) { send method_name.to_sym, *args }
  end
end