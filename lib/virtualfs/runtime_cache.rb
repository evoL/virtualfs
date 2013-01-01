module VirtualFS
  class RuntimeCache
    attr_accessor :expires_after

    def initialize(opts={})
      @expires_after = opts[:expires_after] || -1

      @store = {}
      @times = {}
    end

    def cache(key, &proc)
      access_time = Time.now

      # Invalidate cache after some time
      if (@expires_after > -1) && ((access_time - (@times[key] || access_time)) > @expires_after)
        @times[key] = access_time
        @store[key] = nil
      end

      @times[key] ||= access_time
      @store[key] ||= yield
    end
  end
end