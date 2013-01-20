module VirtualFS
  class File
    attr_reader :path

    def initialize(path, backend)
      @path = VirtualFS.realpath(path)
      @backend = backend
    end

    def name
      @path.rpartition('/').last
    end

    def directory?
      false
    end

    def method_missing(method, *args)
      @stream ||= @backend.stream_for(@path)
      @stream.send(method, *args)
    end

    def inspect
      "<#{@backend.class.name} '#{@path}'>"
    end
  end
end