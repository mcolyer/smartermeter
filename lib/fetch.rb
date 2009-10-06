require 'rubygems'
require 'mechanize'

$USERNAME = ''
$PASSWORD = ''

# All the constants
$LOGIN_URL = "http://www.pge.com/myhome/"
$OVERVIEW_URL = "https://www.pge.com/csol/actions/login.do?aw"
$ENERGYGUIDE_AUTH_URL = "https://www.energyguide.com/LoadAnalysis/LoadAnalysis.aspx?Referrerid=154"

# Let's look normal... 
a = WWW::Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

# Login to PG&E's website
a.get($LOGIN_URL) do |page|
  logged_in_page = page.form_with(:action => 'https://www.pge.com/eum/login') do |login|
    login.USER = $USERNAME
    login.PASSWORD = $PASSWORD
  end.submit
end

# There is a crazy meta-reload thing here that mechanize doesn't handle
# correctly by itself so let's help it along...
a.get($OVERVIEW_URL) do |page|

  # Load up the PG&E frame page for historical data
  hourly_usage_container = a.click(page.links.select{|l| l.text.include? 'Hourly'}.first)

  # Now load up the frame with the content
  hourly_usage = a.click(hourly_usage_container.frames.select{|f| f.href == "/csol/nexus/content.jsp"}.first)

  # Now post the authentication information from PG&E to energyguide.com
  data_page = hourly_usage.form_with(:action => $ENERGYGUIDE_AUTH_URL).submit

  # Now we almost actually have data. However we need to setup the desired
  # parameters first before we can get the exportable data. This really shouldn't
  # be necessary.
  hourly_data = data_page.form_with(:action => "LoadAnalysis.aspx") do |form|
    form.__EVENTTARGET = "objChartSelect$butSubmit"
    form['objTimePeriods$objExport$hidChart'] = "Hourly Usage"
    form['objTimePeriods$objExport$hidChartID'] = 8
    form['objChartSelect$ddChart'] = 8 # Hourly usage

    form['objTimePeriods$objExport$hidTimePeriod'] = "Week"
    form['objTimePeriods$objExport$hidTimePeriodID'] = 3
    form['objTimePeriods$rlPeriod'] = 3

    form['objChartSelect$ccSelectedDate1'] = "10/01/2009"
  end.submit

  # Now the beautiful data...
  hourly_csv = hourly_data.form_with(:action => "LoadAnalysis.aspx") do |form|
    form.__EVENTTARGET = "objTimePeriods$objExport$butExport"
  end.submit

  f = File.new('data.csv', 'w')
  f.write(hourly_csv.body)
  f.close
end
