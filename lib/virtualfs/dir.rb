module VirtualFS
  class Dir
    include Enumerable
    attr_reader :path

    def initialize(path, backend)
      @path = path
      @backend = backend
    end

    def entries
      @backend.entries @path
    end

    def glob(pattern)
      @backend.glob pattern, @path
    end

    def each(&block)
      entries.each(&block)
    end

    def inspect
      "<#{@backend.class.name}:#{@path}>"
    end

    alias_method :[], :glob
  end
end