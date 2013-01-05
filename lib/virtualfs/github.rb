require 'virtualfs/backend'

require 'base64'
require 'stringio'
require 'github_api'

module VirtualFS
  class Github < Backend
    attr_reader :user, :repo, :branch

    def initialize(opts={})
      super opts

      @gh = ::Github.new

      @user = opts.fetch(:user)
      @repo = opts.fetch(:repo)
      @branch = opts.fetch(:branch, 'master')
    end

    def entries(path=nil)
      contents = path.nil? ? toplevel_contents : tree_contents(path)

      map_entries(contents.values, :path) { |item| item.type == 'tree' }
    end

    def glob(pattern, path=nil)
      contents = path.nil? ? internal_items : tree_contents(path, true)

      map_entries(contents.select { |path, _| ::File.fnmatch(pattern, path, ::File::FNM_PATHNAME) }.values, :path) { |item| item.type == 'tree' }
    end

    def stream_for(path)
      item = internal_items.fetch(path)
      raise 'Not a file' unless item.type == 'blob'

      StringIO.new internal_blob(item.sha)
    end

    alias_method :[], :glob

  private

    def internal_items
      cache do
        @gh.git_data.trees.get(@user, @repo, @branch, :recursive => true).tree.reduce({}) { |hash, item| hash[item.path] = item; hash }
      end
    end

    def tree_contents(tree, recursive=false)
      internal_items.select { |item, _| item.start_with?("#{tree}/") && (recursive || !item.slice((tree.length+1)..-1).include?('/')) }
    end

    def toplevel_contents
      internal_items.reject { |item, _| item.include? '/' }
    end

    def internal_blob(sha)
      cache do
        Base64.decode64 @gh.git_data.blobs.get(@user, @repo, sha).content
      end
    end
  end
end