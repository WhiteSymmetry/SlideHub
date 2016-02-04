require 'net/http'
require 'uri'
require 'json'

module WebResource
  extend ActiveSupport::Concern

  def get_json(location, limit = 10)
    result = get_contents(location, limit)
    if result
      JSON.parse(result)
    else
      false
    end
  end

  def get_php_serialized_data(location, limit = 10)
    result = get_contents(location, limit)
    if result
      response = result.dup.force_encoding('utf-8')
      require 'php_serialization/unserializer'
      return PhpSerialization::Unserializer.new.run(response)
    else
      return []
    end
  end

  def get_contents(location, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0
    uri = URI.parse(location)
    begin
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
      end
      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        location = response['location']
        warn "redirected to #{location}"
        get_contents(location, limit - 1)
      else
        puts [uri.to_s, response.value].join(' : ')
        false
      end
    rescue => e
      puts [uri.to_s, e.class, e].join(' : ')
      false
    end
  end
end
