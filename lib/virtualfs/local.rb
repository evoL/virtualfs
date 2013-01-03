require 'virtualfs/backend'
require 'virtualfs/dir'
require 'virtualfs/file'
require 'stringio'

module VirtualFS
  class Local < Backend
    def initialize(opts={})
      super opts

      @path = opts.fetch(:path)
    end

    def entries(path=nil)
      p = path || @path

      contents = ::Dir.glob(::File.join(p, '*'), ::File::FNM_DOTMATCH)

      cache do
        map_entries(contents.slice(2, contents.length)) { |path| ::File.directory? path }
      end
    end

    def glob(pattern, path=nil)
      p = path || @path

      cache do
        map_entries(::Dir.glob(::File.join(p, pattern))) { |path| ::File.directory? path }
      end
    end

    def stream_for(path)
      StringIO.new( open(::File.join(@path, path), 'r') { |io| io.read } )
    end

    alias_method :[], :glob
  end
end