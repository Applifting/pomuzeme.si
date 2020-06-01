class GeoCache < Hash
  alias del delete
end
Geocoder.configure(
  # Geocoding optionsÅ
  # timeout: 3,                 # geocoding service timeout (secs)
  lookup: :google, # name of geocoding service (symbol)
  # ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  language: :cs, # ISO-639 language code
  # use_https: false,           # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  api_key: ENV['GOOGLE_MAPS_BACKEND_API_KEY'], # API key for geocoding service
  cache: GeoCache.new, # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys
  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],
  # Calculation options
  units: :km # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
)
