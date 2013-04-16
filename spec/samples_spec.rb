require 'spec_helper'

describe SmarterMeter::Samples do
  before(:all) do
    @data = File.read(File.join($FIXTURES_DIR, 'data.xml'))
    @date_present = DateTime.new(2013, 4, 10, 0, 0, 0, -7)
  end

  subject { SmarterMeter::Samples.parse_espi(@data) }

  it "can calculate the total number of kilowatt hours used" do
    subject.total_kwh.should be_within(0.1).of(7.49)
  end

  it "can calculate the total number of kilowatt hours used on a specific day" do
    subject.total_kwh_on(@date_present).should be_within(0.1).of(4)
  end

  it "can calculate the total number of kilowatt hours used on a day not given" do
    subject.total_kwh_on(DateTime.new(2010, 9, 27)).should == 0
  end

  it "can access samples for a given day" do
    subject.length.should == 24 * 4 * 2
    subject.each{|s| s.should be_kind_of(SmarterMeter::Sample)}
  end
end
