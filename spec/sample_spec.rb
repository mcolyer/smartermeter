$:.unshift File.join(File.dirname(__FILE__))
require 'spec_helper'

describe SmarterMeter::Sample do
  before(:all) do
    @data = File.read(File.join($FIXTURES_DIR, 'data.xml'))
  end
end
