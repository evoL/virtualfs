# VirtualFS

This is a library that allows you to access various datastores in a unified way. Local FS and Github support in included, feel free to contibute other backends.

The API is designed to be compatible with the standard File and Dir APIs. Currently data access is read-only.

## Installation

Add this line to your application's Gemfile:

    gem 'virtualfs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install virtualfs

## Usage

### Read a file for a local directory

    fs = VirtualFS::Local.new :path => '/home/evol/hello'
    file = fs["hello_world"].first  # fs[pattern] is an alias for fs.glob(pattern)

    file.read

### List the root directory of a Github repository

    fs = VirtualFS::Github.new :user => 'evoL', :repo => 'virtualfs'
    fs.entries

### Find recursively files in subfolders

    fs = VirtualFS::Github.new :user => 'evoL', :repo => 'virtualfs'
    rb_files = fs.glob('**/*.rb')

### Caching

    cache = VirtualFS::FileCache.new :filename => 'file.cache', :expires_after => 3600
    fs = VirtualFS::Github.new :user => 'evoL', :repo => 'virtualfs', :cache => cache

Available cache providers are `RuntimeCache` and `FileCache`.

## The Anatomy of a Backend

A backend is a subclass of `VirtualFS::Backend`. It has to define the following methods:

- `#entries` - lists the contents of a directory, like `Dir.entries`. Optionally accepts a `path` parameter, which specifies the path to the directory that will be listed. By default it lists the root directory of the backend.
- `#glob` - lists files mathing the `pattern`, like `Dir.glob`. Optionally accepts a `path` parameter.
- `#stream_for` - returns an `IO` object for the file specified by the `path` parameter.

The arrays returned by `#entries` and `#glob` are arrays of `VirtualFS::Dir` and `VirtualFS::File` objects, which mimic the API of the respective standard library classes. The `VirtualFS::Backend` class provides the `#map_entries` method for easy creation of those lists within backends.

Basic usage:

    map_entries(paths) { |path| is_directory? path }

Instead of an array of strings you can supply an array of any objects, as long as they have a method for getting the path. The default method for getting the path of an object is `#to_s`.

    map_entries(objects, :get_path) { |obj| obj.is_directory? }

Also, it is possible to cache the results of your code in the backend. It's simple:

    cache { get_your_remote_data }

The remote data will then be cached using the user specified cache provider.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

(c) 2013 Rafał Hirsz. This work is licensed under the terms of the MIT license.