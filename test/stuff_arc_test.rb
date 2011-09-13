$: << File.expand_path("../lib",  __FILE__)
require 'test/unit'
require 'active_model'
require 'stuff_arc'
# require 'active_model'

class StuffArcHelper
  include StuffArc
  include ActiveModel::Serializers::JSON

  class <<self
    attr_accessor :db

    def init_db
      self.db = []
    end
  end

  attr_accessor :foo, :bar
  
  def initialize args = nil
    unless args.nil?
      self.foo = args[:foo] if args[:foo]
      self.bar = args[:bar] if args[:bar]
    end
  end
  
  def ==(other)
    self.foo == other.foo && self.bar == other.bar
  end
  
  def attributes
    {'foo' => @foo, 'bar' => @bar}
  end
  
  def attributes=(hash)
    hash.each do |k,v|
      self.instance_variable_set "@#{k}", v
    end
  end

  def self.all
    [self.new({foo: 'foo', bar: 'bar'}), self.new({foo: 'foo2', bar: 'bar2'})]
  end
  
  def save!
    StuffArcHelper.db << self
  end
end

class StuffArcTest < Test::Unit::TestCase
  # def setup
  #   puts "StuffArcHelper.public_methods: #{StuffArcHelper.public_methods.grep /arc/}"
  # end
  
  # def teardown
  #   fname = StuffArcHelper.to_s.underscore.pluralize + '.json'
  #   [fname, fname + '~'].each do |fn|
  #     File.unlink(fn) if File.exists? fn
  #   end
  # end
  
  def test_methods_exist
    assert StuffArcHelper.respond_to?(:archive), "StuffArcHelper has class method :archive"
    assert StuffArcHelper.respond_to?(:unarchive), "StuffArcHelper has class method :unarchive"
  end
  
  def test_creates_archive
    StuffArcHelper.archive
    fname = StuffArcHelper.to_s.underscore
    assert_equal 'stuff_arc_helper', fname, "underscore should transform class name correctly"
    assert File.exists?('stuff_arc_helpers.json'), "archive creates a file"
  end
  
  def test_reads_archive
    StuffArcHelper.archive
    StuffArcHelper.init_db
    assert_equal [], StuffArcHelper.db, "StuffArcHelper.init_db should empty db"
    StuffArcHelper.unarchive
    assert_equal StuffArcHelper.all, StuffArcHelper.db, "Unarchiving should fill db"
  end
  
  def test_full_path_to_archive
    path = File.join(Dir.pwd, 'path-to-archive')
    Dir.mkdir(path) unless File.exists? path
    StuffArcHelper.archive :lib_dir => path
    assert File.exists?(File.join(path, 'stuff_arc_helpers.json')), "archive should be in #{path}"
    File.unlink File.join(path, 'stuff_arc_helpers.json') if File.exists? File.join(path, 'stuff_arc_helpers.json')
    File.unlink File.join(path, 'stuff_arc_helpers.json~') if File.exists? File.join(path, 'stuff_arc_helpers.json~')
    Dir.rmdir path if File.exists? path
  end
  
  def test_fname_override
    fname = 'foo-stuff'
    StuffArcHelper.archive :fname => fname
    assert File.exists?(fname), "file #{fname} should exist"
    File.unlink(fname) if File.exists? fname
  end
end
