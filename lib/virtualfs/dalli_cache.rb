require 'dalli'

module VirtualFS
  class DalliCache
    attr_accessor :expires_after

    def initialize(opts={})
      @expires_after = opts[:expires_after] || -1

      opts[:expires_in] = [0, @expires_after].max
      opts[:namespace] ||= 'virtualfs'

      @client = Dalli::Client.new(opts[:host], opts)
    end

    def cache(key, &proc)
      value = yield
      return @client.get(key) unless @client.add(key, value)

      value
    end
  end
end
