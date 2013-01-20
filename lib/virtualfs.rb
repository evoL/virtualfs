require "virtualfs/version"

module VirtualFS
  @@SELF_RX = /(\/|^)\.(\/|$)/
  @@PARENT_RX = /([^\/.]+\/|^\/?)\.\.(\/|$)/

  def self.realpath(path)
    return nil if path.nil?

    # Remove . dirs
    p = path.gsub @@SELF_RX, '\2'

    # Remove .. dirs
    while p =~ @@PARENT_RX
      p.gsub! @@PARENT_RX, ''
    end

    # Keep a slash at the beginning, remove at the end
    '/' << p.sub(%r{^/+}, '').chomp('/')
  end
end

# Backends
require "virtualfs/local"
require "virtualfs/github"

# Caches
require "virtualfs/runtime_cache"
require "virtualfs/file_cache"
