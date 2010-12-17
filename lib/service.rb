require 'mechanize'
require 'csv'

class SmartMeterService
  LOGIN_URL = "http://www.pge.com/myhome/"
  OVERVIEW_URL = "https://www.pge.com/csol/actions/login.do?aw"
  ENERGYGUIDE_AUTH_URL = "https://www.energyguide.com/LoadAnalysis/LoadAnalysis.aspx?Referrerid=154"

  def initialize
    @agent = WWW::Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    @samples = {}
  end

  def login(username, password)
    @agent.get(LOGIN_URL) do |page|
      logged_in_page = page.form_with(:action => 'https://www.pge.com/eum/login') do |login|
        login.USER = username
        login.PASSWORD = password
      end.submit
    end

    # There is a crazy meta-reload thing here that mechanize doesn't handle
    # correctly by itself so let's help it along...
    @agent.get(OVERVIEW_URL) do |page|

      # Load the PG&E Terms of Use page
      tou_page = @agent.click(page.link_with(:href => '/csol/actions/billingDisclaimer.do?actionType=hourly'))
      form = tou_page.forms().first
      agree_button = form.button_with(:value => 'I Understand - Proceed')
      # Agree to the terms of use
      form['agreement'] = 'yes'

      # Load up the PG&E frame page for historical data
      hourly_usage_container = form.submit(agree_button)

      # Now load up the frame with the content
      hourly_usage = @agent.click(hourly_usage_container.frames.select{|f| f.href == "/csol/nexus/content.jsp"}.first)

      # Now post the authentication information from PG&E to energyguide.com
      @data_page = hourly_usage.form_with(:action => ENERGYGUIDE_AUTH_URL).submit
    end
  end

  def fetch_day(date)
    return @samples[date] if @samples.has_key? date

    parse_csv(fetch_csv(date))[date]
  end

  def fetch_csv(date)
    # TODO: Check if the authentication has been called

    # Now we almost actually have data. However we need to setup the desired
    # parameters first before we can get the exportable data. This really shouldn't
    # be necessary.
    hourly_data = @data_page.form_with(:action => "/LoadAnalysis/LoadAnalysis.aspx") do |form|
      form['__EVENTTARGET'] = "objChartSelect$butSubmit"
      form['objTimePeriods$objExport$hidChart'] = "Hourly Usage"
      form['objTimePeriods$objExport$hidChartID'] = 8
      form['objChartSelect$ddChart'] = 8 # Hourly usage

      form['objTimePeriods$objExport$hidTimePeriod'] = "Week"
      form['objTimePeriods$objExport$hidTimePeriodID'] = 3
      form['objTimePeriods$rlPeriod'] = 3

      form['objChartSelect$ccSelectedDate1'] = date.strftime("%m/%d/%Y")
    end.submit

    # Now the beautiful data...
    hourly_csv = hourly_data.form_with(:action => "/LoadAnalysis/LoadAnalysis.aspx") do |form|
      form['__EVENTTARGET'] = "objTimePeriods$objExport$butExport"
    end.submit

    hourly_csv.body
  end

  protected
    def parse_csv(data)
      date_re = /([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})/

      # Apparently they felt the need to put a = outside of the correct place
      data = data.gsub('=','')

      hour_increment = 1/24.0 
      CSV.parse(data) do |row|
        next unless row.length > 0 and date_re.match row[0]

        month, day, year = date_re.match(row[0]).captures
        month = month.to_i
        day = day.to_i
        year = year.to_i

        timestamp = DateTime.new(year, month, day, 0, 0, 0) - hour_increment + 1/(24.0*60)
        hourly_samples = row[1..24].map do |v|
          kwh = v.to_f
          timestamp = timestamp + hour_increment
          Sample.new(timestamp, kwh)
        end
        @samples[Date.new(year, month, day)] = hourly_samples
      end
      @samples
    end
end
