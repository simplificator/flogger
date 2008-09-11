#$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed
require 'flogger/assertions'
require 'test/unit'
require 'rubygems'
require 'flog'
Test::Unit::TestCase.send(:include, Flogger::InstanceMethods)

puts 'loaded flogger'