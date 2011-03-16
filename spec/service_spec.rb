$:.unshift File.join(File.dirname(__FILE__))
require 'spec_helper'

describe SmarterMeter::Service do
  before(:each) do
    @subject = SmarterMeter::Service.new
  end
end
