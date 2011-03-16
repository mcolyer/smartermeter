$:.unshift File.join(File.dirname(__FILE__))
require 'spec_helper'

describe SmarterMeter::Sample do
  before(:all) do
    @data = File.read(File.join($FIXTURES_DIR, 'data.csv'))
  end

  it "should be able to parse csv data returned by the api" do
    date = Date.new(2009, 9, 27)
    results = SmarterMeter::Sample.parse_csv(@data)

    results.length.should == 7
    results.keys.should include(date)
    results[date].length.should == 24
    results[date].each{|s| s.should be_kind_of(SmarterMeter::Sample)}

    results[date][0].kwh.should == nil
    results[date][0].time.should == Time.local(2009, 9, 27, 0)

    results[date][1].kwh.should == 0.205
    results[date][1].time.should == Time.local(2009, 9, 27, 1)
  end
end
