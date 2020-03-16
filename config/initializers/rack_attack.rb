# Using the `rack-attack` and `cloudflare-rails` gems.
# Set ENV["REJECT_UNPROXIED_REQUESTS"] in protected environments.

class Rack::Attack
  if ENV['REJECT_UNPROXIED_REQUESTS']
    blocklist('block non-proxied requests in production') do |request|
      raw_ip = request.get_header('HTTP_X_FORWARDED_FOR')
      ip_addresses = raw_ip ? raw_ip.strip.split(/[,\s]+/) : []
      proxy_ip = ip_addresses.last

      if request.host !~ /heroku/ && ::Rails.application.config.cloudflare.ips.any? { |proxy| proxy === proxy_ip }
        false
      else
        ::Rails.logger.warn "Rack Attack IP Filtering: blocked request from #{proxy_ip} to #{request.url}"
        true
      end
    end
  end
end
