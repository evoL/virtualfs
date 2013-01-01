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
  end
end