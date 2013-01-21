require 'virtualfs/backend'
require 'virtualfs/dir'
require 'virtualfs/file'
require 'stringio'

module VirtualFS
  class Local < Backend
    def initialize(opts={})
      super opts

      @path = ::File.realpath(opts.fetch(:path))
    end

    def entries(path='/')
      p = VirtualFS.realpath(path)

      contents = ::Dir.entries(::File.join(@path, p)).map { |entry| ::File.join(p, entry) }

      cache do
        map_entries(contents) { |path| ::File.directory?(::File.join(@path, path)) }
      end
    end

    def glob(pattern, path='/')
      p = VirtualFS.realpath(path)

      contents = ::Dir.glob(::File.join(@path, p, pattern)).map { |entry| entry.sub(@path, '') }

      cache do
        map_entries(contents) { |path| ::File.directory?(::File.join(@path, path)) }
      end
    end

    def stream_for(path)
      path = VirtualFS.realpath(path)

      StringIO.new( ::File.open(::File.join(@path, path), 'r') { |io| io.read } )
    end

    alias_method :[], :glob
  end
end