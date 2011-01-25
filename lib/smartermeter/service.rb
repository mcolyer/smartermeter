require 'mechanize'
require 'csv'

module SmarterMeter
  class Service
    LOGIN_URL = "http://www.pge.com/myhome/"
    OVERVIEW_URL = "https://www.pge.com/csol/actions/login.do?aw"
    ENERGYGUIDE_AUTH_URL = "https://www.energyguide.com/LoadAnalysis/LoadAnalysis.aspx?Referrerid=154"

    attr_reader :last_page
    attr_reader :last_exception

    def initialize
      @agent = WWW::Mechanize.new { |agent|
        agent.user_agent_alias = 'Mac Safari'
      }
    end

    # Returns true upon succesful login and false otherwise
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
      rescue SocketError => e
        @last_exception = e
        return false
      end

      true
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
  end
end
