require 'mechanize'
require 'csv'
require 'tempfile'
require 'zip/zip'
require 'uri'

module SmarterMeter
  # Provides access to the PG&E SmartMeter data through a ruby interface. This
  # class depends on the PG&E website to function the same that it does today,
  # so if something stops working its likely that something changed on PG&E's
  # site and this class will need to be adapted.
  class Service
    LOGIN_FORM_URL = "http://www.pge.com/"
    LOGIN_URL = "https://www.pge.com/eum/login"
    MY_USAGE_URL = "https://www.pge.com/myenergyweb/appmanager/pge/customer?_nfpb=true&_pageLabel=MyUsage"
    SAML_URL = "https://sso.opower.com/sp/ACS.saml2"
    MY_ENERGY_USE_URL = "https://pge.opower.com/ei/app/myEnergyUse"

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
        @agent.get(LOGIN_FORM_URL) do |page|
          saml_page = page.form_with(:action => LOGIN_URL) do |login|
            login.USER = username
            login.PASSWORD = password
            login.TARGET = MY_USAGE_URL
          end.submit
          token = saml_page.form_with(:action => SAML_URL).submit
          usage_page = token.form_with(:action => MY_ENERGY_USE_URL).submit
          @data_page = usage_page.link_with(:text => "Green Button").click
        end
        @authenticated = true
      rescue Exception => e
        @last_exception = e
        return false
      end
    end

    # Downloads an ESPI file containing data in 15 minute windows on the
    # given date.
    #
    # @param [Time] date - The day of the data you wish to fetch.
    # @return [String] the XML data.
    def fetch_espi(date)
      raise RuntimeException, "login must be called before fetch_espi" unless @authenticated

      begin
        form = @data_page.forms.first
        form.radiobutton_with(:name => 'exportFormat', :value => 'ESPI_INTERVAL').check
        form['from'] = date.strftime("%m/%d/%Y")
        form['to'] = date.strftime("%m/%d/%Y")
        espi_xml_zip = form.submit

        # This has to be one of the stupidest implementations I've seen
        # of a ruby library. Why on earth can you not pass in an IO
        # object to the rubyzip library?
        file = Tempfile.new('espi-zip')
        begin
          file.binmode
          file << espi_xml_zip.body
          file.flush
          file.close

          Zip::ZipInputStream::open(file.path) do |contents|
            while (entry = contents.get_next_entry)
              if (entry.name =~ /pge_electric_interval_data/) then
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
