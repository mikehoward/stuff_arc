$: << File.expand_path("../lib",  __FILE__)
require 'test/unit'
require 'rails'
require 'active_record'
require 'stuff_arc'

# FIXME: This test doesn't work w/o the rails db infrastructure. Don't have time to fix it now

class EngineTestHelper < ActiveRecord::Base
end
tmp = EngineTestHelper.new
puts "EngineTestHelper.public_methods.grep /archive/: #{EngineTestHelper.public_methods.grep /archive/}"

class EngineTest < Test::Unit::TestCase
  def test_responds_to_archive
    assert EngineTestHelper.respond_to?(:archive), "EngineTestHelper responds to :archive"
  end
end
