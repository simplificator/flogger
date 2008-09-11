require 'flogger'
require 'test/unit'
#
# Hackhack. Making a private method public (without using send()
#
module Flogger::InstanceMethods
  def public_extract_files_and_options(*args)
    extract_files_and_options(args)
  end
end

class TestChronic < Test::Unit::TestCase
  
  def setup
   
  end

  
  def test_assert_flog
    assert_flog(__FILE__, :limit => 0)
  end
  
  
  def test_extract_files_and_options
    files, options = public_extract_files_and_options('some')
    assert_equal(['some'], files)
    assert_equal({}, options)
    
    files, options = public_extract_files_and_options('some', 'other')
    assert_equal(['some', 'other'], files)
    assert_equal({}, options)
    
    
    files, options = public_extract_files_and_options('some', 'other', :key => :value)
    assert_equal(['some', 'other'], files)
    assert_equal({:key => :value}, options)
  end
end


