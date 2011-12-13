require 'mechanize'
require 'csv'
require 'tempfile'
require 'zip/zip'

module SmarterMeter
  # Provides access to the PG&E SmartMeter data through a ruby interface. This
  # class depends on the PG&E website to function the same that it does today,
  # so if something stops working its likely that something changed on PG&E's
  # site and this class will need to be adapted.
  class Service
    LOGIN_URL = "https://www.pge.com/csol"
    OVERVIEW_URL = "https://www.pge.com/myenergyweb/appmanager/pge/customer?_nfpb=true&_pageLabel=MyUsage"
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
        agent.log = Logger.new("mech.log")
      }
      @logger = Logger.new STDOUT
      @logger.level = Logger::INFO
    end

    # Authenticates to the PG&E's website. Only needs to be performed once per
    # instance of this class.
    #
    # @return [Boolean] true upon succesful login and false otherwise
    def login(username, password)
      begin
        @agent.get(LOGIN_URL) do |page|
          logged_in_page = page.form_with(:name => 'login') do |login|
            login.USER = username
            login.PASSWORD = password
          end.submit
        end

        # There is a crazy meta-reload thing here that mechanize doesn't handle
        # correctly by itself so let's help it along...
        @agent.get(OVERVIEW_URL) do |page|

          return false if page.title =~ /PG&E Login/

          # Now post the authentication information from PG&E to energyguide.com
          saml_page = page.forms().first.submit
          overview_page = saml_page.forms().first.submit

          @data_page = @agent.click(overview_page.link_with(:text => /Export your data/))
        end
        @authenticated = true
      rescue Exception => e
        @last_exception = e
        return false
      end
    end

    # Downloads a CSV containing hourly data on that date. Up to a month worth
    # of other data will be included depending on which day you request.
    #
    # PG&E compiles this data on a weekly schedule so if you ask for Monday
    # you'll get the previous Sunday and the following days upto the next
    # Sunday. [is this still true?]
    #
    # @return [String] the CSV data.
    def fetch_csv(date)
      raise RuntimeException, "login must be called before fetch_csv" unless @authenticated

      # Now we almost actually have data. However we need to setup the desired
      # parameters first before we can get the exportable data. This really shouldn't
      # be necessary.
      begin
        form = @data_page.forms().first
        begin
          form.radiobuttons_with(:value => 'CSV_INTERVAL').each { |f| f.click }
          form.field_with(:name => 'bill').value = date.strftime("%Y-%m")
        end
        hourly_csv = form.submit

        file = Tempfile.new('hourly')
        begin
          file.binmode
          file << hourly_csv.body.strip
          file.flush
          file.close

          Zip::ZipInputStream::open(file.path()) do |contents|
            while (entry = contents.get_next_entry)
              if (entry.name =~ /DailyElectricUsage/) then
                return contents.read
              end
            end
          end
        ensure
          file.close
          file.unlink
        end
      rescue Exception => e
        @last_exception = e
        return ""
      end
    end
  end
end
