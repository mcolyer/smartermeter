require 'mechanize'
require 'csv'

module SmarterMeter
  # Provides access to the PG&E SmartMeter data through a ruby interface. This
  # class depends on the PG&E website to function the same that it does today,
  # so if something stops working its likely that something changed on PG&E's
  # site and this class will need to be adapted.
  class Service
    LOGIN_URL = "http://www.pge.com/myhome/"
    OVERVIEW_URL = "https://www.pge.com/csol/actions/login.do?aw"
    ENERGYGUIDE_AUTH_URL = "https://www.energyguide.com/LoadAnalysis/LoadAnalysis.aspx?Referrerid=154"

    # Provides access to the last page retrieved by mechanize. Useful for
    # debugging and reporting errors.
    attr_reader :last_page

    # Provides access to the last exception thrown while accessing PG&E's site.
    # Useful for debugging/error reporting.
    attr_reader :last_exception

    def initialize
      @agent = Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
    end

    # Authenticates to the PG&E's website. Only needs to be performed once per
    # instance of this class.
    #
    # @return [Boolean] true upon succesful login and false otherwise
    def login(username, password)
      begin
        @agent.get(LOGIN_URL) do |page|
          logged_in_page = page.form_with(:action => 'https://www.pge.com/eum/login') do |login|
            login.USER = username
            login.PASSWORD = password
          end.submit
        end

        # There is a crazy meta-reload thing here that mechanize doesn't handle
        # correctly by itself so let's help it along...
        @agent.get(OVERVIEW_URL) do |page|

          return false if page.title =~ /PG&E Login/

          # Load the PG&E Terms of Use page
          tou_link = page.link_with(:href => '/csol/actions/billingDisclaimer.do?actionType=hourly')
          unless tou_link
            @last_page = page
            return false
          end
          tou_page = @agent.click(tou_link)
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
        @authenticated = true
      rescue Exception => e
        @last_exception = e
        return false
      end
    end

    # Downloads a CSV containing hourly date on that date. Up to a week worth
    # of other data will be included depending on which day of the week that
    # you request.
    #
    # PG&E compiles this data on a weekly schedule so if you ask for Monday
    # you'll get the previous Sunday and the following days upto the next
    # Sunday.
    #
    # @return [String] the CSV data.
    def fetch_csv(date)
      raise RuntimeException, "login must be called before fetch_csv" unless @authenticated

      # Now we almost actually have data. However we need to setup the desired
      # parameters first before we can get the exportable data. This really shouldn't
      # be necessary.
      begin
        hourly_data = @data_page.form_with(:action => "LoadAnalysis.aspx") do |form|
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
        hourly_csv = hourly_data.form_with(:action => "LoadAnalysis.aspx") do |form|
          form['__EVENTTARGET'] = "objTimePeriods$objExport$butExport"
        end.submit

        hourly_csv.body
      rescue Timeout::Error => e
        @last_exception = e
        return ""
      end
    end
  end
end
