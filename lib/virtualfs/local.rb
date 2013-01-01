require 'virtualfs/backend'
require 'virtualfs/runtime_cache'
require 'virtualfs/dir'
require 'virtualfs/file'
require 'stringio'

module VirtualFS
  class Local < Backend
    def initialize(opts={})
      super opts

      @path = opts.fetch(:path)
      @stream_cache = RuntimeCache.new
    end

    def entries(path=nil)
      p = path || @path

      cache do
        list = ::Dir.entries(p)
        list.slice(2, list.length).map do |entry|
          file = ::File.join(p, entry)

          if ::File.directory?(file)
            VirtualFS::Dir.new(file, self)
          else
            VirtualFS::File.new(file, self)
          end
        end
      end
    end

    def glob(pattern, path=nil)
      p = path || @path

      cache do
        results = ::Dir.glob(::File.join(p, pattern)).map do |entry|
          if ::File.directory?(entry)
            VirtualFS::Dir.new(entry, self)
          else
            VirtualFS::File.new(entry, self)
          end
        end

        results.length == 1 ? results.first : results
      end
    end

    def stream_for(path)
      @stream_cache.cache(path) do
        StringIO.new( open(::File.join(@path, path), 'r') { |io| io.read } )
      end
    end

    alias_method :[], :glob
  end
end