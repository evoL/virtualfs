require 'virtualfs'
require 'fakefs/safe'

class FakeFS::File
  def self.realpath(p)
    RealFile.realpath(p)
  end
end

describe VirtualFS::Local do
  let(:fs) { VirtualFS::Local.new :path => '/' }

  context 'when the directory is empty' do
    before :all do
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end
    after :all do
      FakeFS.deactivate!
    end

    it 'contains only the . and .. entries' do
      fs.entries.map(&:name).should == ['.', '..']
    end

    it 'glob is empty' do
      fs.glob('*').should be_empty
    end
  end

  context 'when the directory is not empty' do
    before :all do
      FakeFS.activate!
      FakeFS::FileSystem.clear

      FileUtils.mkdir_p '/a/b'
      FileUtils.mkdir_p '/b'
      FileUtils.touch '/content.txt'
      FileUtils.touch '/test.txt'
      FileUtils.touch '/a/test.txt'
      FileUtils.touch '/b/test.txt'
      FileUtils.touch '/a/b/test.txt'

      File.open('/content.txt', "w") do |file|
        file.puts 'Line 1'
        file.puts 'Line 2'
        file.puts 'Line 3'
      end
    end
    after :all do
      FakeFS.deactivate!
    end

    it '#[] works exactly like #glob' do
      fs['*'].map(&:path).should == fs.glob('*').map(&:path)
    end

    it 'passing the exact filename returns a list of 1 element' do
      result = fs['test.txt']

      result.should be_instance_of(Array)
      result.length.should eq(1)
      result.first.name.should == 'test.txt'
    end

    it '. points to the same directory' do
      fs['.'].first.path.should eq('/')
      fs['a'].first.glob('.').first.path.should == '/a'
    end

    it '.. on root level point to the same directory' do
      fs['..'].first.path.should == '/'
    end

    it '.. points to the parent directory when not in root directory' do
      fs['a'].first.glob('..').first.path.should == '/'
    end

    it '#entries lists the top level' do
      names = fs.entries.map(&:name)

      names.should include('.')
      names.should include('..')
      names.should include('a')
      names.should include('b')
      names.should include('content.txt')
      names.should include('test.txt')
    end

    it '#glob does not list . and ..' do
      names = fs['*'].map(&:name)

      names.should_not include('.')
      names.should_not include('..')
    end

    it '#glob supports recursive patterns' do
      paths = fs['**/*.txt'].map(&:path)

      paths.should include('/a/test.txt')
      paths.should include('/b/test.txt')
      paths.should include('/a/b/test.txt')
    end

    it '#glob returns an empty list when looking for a nonexistent file' do
      fs['nonexistent.txt'].should be_empty
    end

    it 'reopens the stream every time' do
      fs['content.txt'].first.readline.should eq("Line 1\n")
      fs['content.txt'].first.readline.should eq("Line 1\n")
    end

    it 'does not reopen the stream when assigned to a variable' do
      s = fs['content.txt'].first
      s.readline.should eq("Line 1\n")
      s.readline.should eq("Line 2\n")
    end
  end
end