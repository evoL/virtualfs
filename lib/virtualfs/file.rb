module VirtualFS
  class File
    attr_reader :path

    def initialize(path, backend)
      @path = path
      @backend = backend
    end

    def method_missing(method, *args)
      @backend.stream_for(@path).send(method, *args)
    end

    def inspect
      "<#{@backend.class.name}:#{@path}>"
    end
  end
end