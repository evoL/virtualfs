require 'virtualfs/backend'

require 'base64'
require 'stringio'
require 'octokit'
require 'unicode'

module VirtualFS
  class Github < Backend
    attr_reader :user, :repo, :branch

    def initialize(opts={})
      super opts

      @user = opts.fetch(:user)
      @repo = opts.fetch(:repo)
      @branch = opts.fetch(:branch, 'master')
      auth = opts.fetch(:authentication, {})

      # @gh = ::Github::GitData.new(opts)
      @gh = Octokit::Client.new(auth)
    end

    def entries(path='/')
      path = '/' << path unless path.start_with? '/'
      p = path[1..-1]

      contents = path == '/' ? toplevel_contents : tree_contents(p)
      dotfolders_for(path) + map_entries(contents.values, :path) { |item| item.type == 'tree' }
    end

    def glob(pattern, path='/')
      path = '/' << path unless path.start_with? '/'
      p = path[1..-1]

      contents = path == '/' ? internal_items : tree_contents(p, true)
      map_entries(contents.select { |path, _| ::File.fnmatch(pattern, path, ::File::FNM_PATHNAME) }.values, :path) { |item| item.type == 'tree' }
    end

    def stream_for(path)
      path = '/' << path unless path.start_with? '/'
      p = path[1..-1]

      item = internal_items.fetch(p)
      raise 'Not a file' unless item.type == 'blob'

      StringIO.new internal_blob(item.sha)
    end

    alias_method :[], :glob

    private

    def internal_items
      cache do
        @gh.tree("#{@user}/#{@repo}", @branch, :recursive => true).tree.reduce({}) do |hash, item|
          # Handle decomposed UTF-8 in Github's response
          path = fix_utf8(item.path)

          hash[path] = item
          hash
        end
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
        Base64.decode64 @gh.blob("#{@user}/#{@repo}", sha).content
      end
    end

    def fix_utf8(string)
      Unicode::normalize_C(string)
    end
  end
end
