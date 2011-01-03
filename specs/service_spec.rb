$:.unshift File.join(File.dirname(__FILE__))
require 'spec_helper'

describe "Service" do
  before(:each) do
    @subject = SmarterMeter::Service.new
    @date = Date.new(2009, 9, 30)
    @data = File.read(File.join($FIXTURES_DIR, 'data.csv'))
  end

  it "should be able to parse csv data returned by the api" do
    results = @subject.parse_csv(@data)

    results.length.should > 0
    results.keys.should include(@date)
    results[@date].length.should == 24
    results[@date].each{|s| s.should be_kind_of(SmarterMeter::Sample)}
  end
end
