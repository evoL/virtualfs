require 'virtualfs/dir'
require 'virtualfs/file'

module VirtualFS
  class NullCache
    def cache(key)
      yield
    end
  end

  class Backend
    def initialize(opts={})
      @cache = opts[:cache] || NullCache.new
    end

    def cache(&proc)
      local_variable_values = eval('local_variables.map { |var| eval(var.to_s) }', proc.binding)
      key = caller[0] << local_variable_values.inspect
      @cache.cache(key, &proc)
    end

    def map_entries(paths, method=:to_s, &dir_criteria)
      paths.map do |path|
        if dir_criteria.call(path)
          VirtualFS::Dir.new(path.send(method), self)
        else
          VirtualFS::File.new(path.send(method), self)
        end
      end
    end

    def dotfolders_for(path)
      [VirtualFS::Dir.new(::File.join(path, '.'), self), VirtualFS::Dir.new(::File.join(path, '..'), self)]
    end

    def entries(path=nil)
      # override this
      raise NotImplementedError
    end

    def glob(pattern, path=nil)
      # override this
      raise NotImplementedError
    end

    def stream_for(path)
      # override this
      raise NotImplementedError
    end

    alias_method :[], :glob
  end
end