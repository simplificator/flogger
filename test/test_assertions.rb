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

class TestAssertions < Test::Unit::TestCase
  def test_assert_flog_raises
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_flog(__FILE__) 
    end
  end
  
  # flog score of > 9
  def test_tresholds
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_flog(__FILE__, :treshold => 10) 
    end
    assert_raise(Test::Unit::AssertionFailedError) do
      assert_flog(__FILE__, :treshold => 30, :tresholds => {'TestAssertions#test_extract_files_and_options' => 20}) 
    end
    
    assert_flog(__FILE__, :treshold => 10, :tresholds => {'TestAssertions#test_extract_files_and_options' => 23})
  end
  
  # flog score of > 22
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
    
    files, options = public_extract_files_and_options('some', 'other', {})
    assert_equal(['some', 'other'], files)
    assert_equal({}, options)
  end
end


