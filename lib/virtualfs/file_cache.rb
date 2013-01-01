require 'pstore'

module VirtualFS
  class FileCache
    attr_accessor :expires_after

    def initialize(opts={})
      @expires_after = opts[:expires_after] || -1

      @store = PStore.new(opts[:filename] || 'virtualfs.pstore')
    end

    def cache(key, &proc)
      access_time = Time.now

      @store.transaction do
        data = @store[key] || {:time => access_time, :content => nil}

        # Invalidate cache after some time
        if (@expires_after > -1) && ((access_time - data[:time]) > @expires_after)
          data = {:time => access_time, :content => nil}
        end

        data[:content] ||= yield
        @store[key] = data

        data[:content]
      end
    end
  end
end