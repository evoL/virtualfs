module VirtualFS
  class Dir
    include Enumerable

    def initialize(path, backend)
      @path = path
      @realpath = VirtualFS.realpath(path)
      @backend = backend
    end

    def path
      @realpath
    end

    def name
      name = @path.rpartition('/').last
      name.empty? ? '/' : name
    end

    def directory?
      true
    end

    def entries
      @backend.entries @realpath
    end

    def glob(pattern)
      @backend.glob pattern, @realpath
    end

    def each(&block)
      entries.each(&block)
    end

    def inspect
      if ['.','..'].include? name
        p = @path
      else
        p = @realpath
      end

      "<#{@backend.class.name} '#{p}' (dir)>"
    end

    alias_method :[], :glob
  end
end