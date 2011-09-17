require 'logger'
require 'profligacy/swing'
require 'profligacy/lel'

module SmarterMeter
  # @private
  module Interfaces
    class Swing
      include_package "java.awt"

      LogFile = File.expand_path("~/.smartermeter.log")

      def initialize
        # TODO: Implement a way to update the settings
        #settings_item = MenuItem.new("Settings")
        #settings_item.add_action_listener { SettingsWindow.new do |config|
        #    puts config.inspect
        #  end
        #}

        update_item = MenuItem.new("Check for Updates")
        update_item.add_action_listener do
          desktop = Desktop.getDesktop();
          uri = Java::JavaNet::URI.new("http://matt.colyer.name/projects/smartermeter/?v=#{SmarterMeter::VERSION}")
          desktop.browse(uri)
        end

        log_item = MenuItem.new("View Log")
        log_item.add_action_listener do
          LogWindow.new {}
        end

        exit_item = MenuItem.new("Exit")
        exit_item.add_action_listener {java.lang.System::exit(0)}


        popup = PopupMenu.new
        popup.add(update_item)
        popup.add(log_item)
        popup.add(MenuItem.new("-"))
        popup.add(exit_item)

        image = Toolkit::default_toolkit.get_image("icons/smartermeter-16x16.png")
        tray_icon = TrayIcon.new(image, "SmarterMeter", popup)
        tray_icon.image_auto_size = true

        tray = SystemTray::system_tray
        tray.add(tray_icon)
      end

      # Returns a logger like interface to log errors and warnings to.
      def log
        return @logger if @logger
        @logger = Logger.new(LogFile)
        @logger.level = Logger::INFO
        @logger
      end

      # Public: Called when ~/.smartermeter needs to be configured.
      # Yields a hash containing the configuration specified by the user.
      #
      # Returns nothing.
      def setup
        Wizard.new do |config|
          yield config
        end
      end
    end

    class SettingsWindow
      include_package "javax.swing"

      def initialize(&block)
        UIManager.set_look_and_feel(UIManager.get_system_look_and_feel_class_name)

        layout = "
            [ username_label | (150)username_field ]
            [ password_label | (150)password_field ]
            [ _ | >save_button ]
        "

        @ui = Profligacy::Swing::LEL.new(JFrame, layout) do |c,i|
          c.username_label = JLabel.new "PG&E Username:"
          c.username_field = JTextField.new
          c.password_label = JLabel.new "PG&E Password:"
          c.password_field = JPasswordField.new
          c.save_button = JButton.new("Save")

          i.save_button = { :action => proc do |t, e|
              config = {
                :username => @ui.username_field.text,
                :password => @ui.password_field.text
              }
              @frame.dispose
              yield config
            end
          }
        end

        @frame = @ui.build(:args => "SmarterMeter Settings")
        @frame.set_location_relative_to(nil)
        @frame.default_close_operation = JFrame::DISPOSE_ON_CLOSE
      end
    end

    class LogWindow
      include_package "javax.swing"

      LogFile = File.expand_path("~/.smartermeter.log")

      def initialize(&block)
        UIManager.set_look_and_feel(UIManager.get_system_look_and_feel_class_name)

        layout = "
            [ log_label  ]
            [ (600,200)*log_area ]
            [ >buttons ]
        "

        log = File.read(LogFile)

        @ui = Profligacy::Swing::LEL.new(JFrame, layout) do |c,i|
          c.log_label = JLabel.new "Log:"

          textarea = JTextArea.new(log)
          textarea.set_caret_position(textarea.get_text().length())
          c.log_area = JScrollPane.new(textarea)

          c.buttons = Profligacy::Swing::LEL.new(JPanel, "[clear|close]") do |cc,ii|
            cc.clear = JButton.new "Clear"
            ii.clear = { :action => proc do |t, e|
                File.open(LogFile, "w") { |f| f.write("") }
                textarea.text = ""
              end
            }
            cc.close = JButton.new "Close"
            ii.close = { :action => proc do |t, e|
                @frame.dispose
                yield
              end
            }
          end.build :auto_create_container_gaps => false
        end

        @frame = @ui.build(:args => "SmarterMeter Log")
        @frame.set_location_relative_to(nil)
        @frame.default_close_operation = JFrame::DISPOSE_ON_CLOSE
      end
    end

    # @private
    class Wizard
      include_package "javax.swing"
      include_package "java.awt"

      def initialize
        UIManager.set_look_and_feel(UIManager.get_system_look_and_feel_class_name)

        layout = "
            [ panel ]
            [ rule ]
            [ >buttons ]
        "

        @page_index = 0

        @wizard = Profligacy::Swing::LEL.new(JFrame, layout) do |c,i|
          c.rule = JSeparator.new

          @buttons = Profligacy::Swing::LEL.new(JPanel, "[back|next|>gap|cancel]") do |cc,ii|
            cc.back = JButton.new "Back"
            cc.back.minimum_size = Dimension.new(50,14)
            cc.back.visible = false
            ii.back = { :action => method(:show_previous_page) }

            cc.next = JButton.new "Next"
            cc.next.minimum_size = Dimension.new(50,14)
            cc.next.enabled = false
            ii.next = { :action => method(:show_next_page) }

            cc.gap = Box.create_horizontal_strut(10)

            cc.cancel = JButton.new "Cancel"
            cc.cancel.minimum_size = Dimension.new(50,14)
            ii.cancel =  { :action => proc do |t, e|
                if cc.cancel.text == "Complete"
                  config = {
                    :username => @pages[0].username,
                    :password => @pages[0].password,
                    :transport => :pachube,
                    :pachube => {
                      :api_key => @pages[1].api_key,
                      :feed_id => @pages[1].feed_id,
                      :datastream_id => @pages[1].datastream_id
                    }
                  }
                else
                  config = {}
                end

                @frame.dispose
                yield config
              end
            }
          end
          c.buttons = @buttons.build

          @panel = JPanel.new(CardLayout.new)
          @pages = [PGEPage, PachubePage, CompletePage].map do |klass|
            page = klass.new(@buttons)
            @panel.add(page.build, klass.to_s)
            page
          end
          c.panel = @panel
        end

        @frame = @wizard.build(:args => "SmarterMeter Setup", :auto_create_container_gaps => false) do |frame|
          frame.default_close_operation = JFrame::DISPOSE_ON_CLOSE
          frame.set_size(560, 400)
          frame.set_location_relative_to(nil) # Centers on screen
        end
      end

      # Public: Presents the next page of the wizard.
      #
      # type  - The symbol representing the name of the event called
      # event - The Java::Awt::Event that was triggered.
      #
      # Returns nothing.
      def show_next_page(type, event)
        @page_index += 1
        configure_buttons

        @panel.get_layout.next(@panel)
      end

      # Public: Presents the previous page of the wizard.
      #
      # type  - The symbol representing the name of the event called
      # event - The Java::Awt::Event that was triggered.
      #
      # Returns nothing.
      def show_previous_page(type, event)
        @page_index -= 1
        configure_buttons

        @panel.get_layout.previous(@panel)
      end

    protected

      def configure_buttons
        @pages[@page_index].validate

        if @page_index > 0
          @buttons.back.visible = true
        else
          @buttons.back.visible = false
        end

        if @page_index == @pages.size - 1
          @buttons.next.visible = false
          @buttons.cancel.text = "Complete"
        else
          @buttons.next.visible = true
          @buttons.cancel.text = "Cancel"
        end
      end

      module WizardPage
        include_package "javax.swing"
        include_package "java.awt"

        # Protected: Creates a panel that includes the header at the top, in
        # a standard wizard visual format.
        #
        # It expects a block, which yields a Profligacy::Swing::LEL object
        # to attach components and events to.
        #
        #     header("Title", "Message") do |c|
        #       c.controls = JButton.new("Hello World!")
        #     end
        #
        # title    - The text to show in the header as the title.
        # message  - The text to show under the title in the header.
        # controls - True adds a controls area to the page, false ignores it.
        #            Defaults to true.
        #
        # Returns nothing.
        def header(title, message, controls=true)
          layout = "
            [ (560,100)*header ]
          "
          layout += "[ controls ]" if controls

          @panel = Profligacy::Swing::LEL.new(JPanel, layout) do |c,i|
            header_layout = "
                [ <title ]
                [ <message ]
            "
            @header = Profligacy::Swing::LEL.new(JPanel, header_layout) do |cc,ii|
              cc.title = JLabel.new title
              cc.message = JEditorPane.new "text/html", message
              cc.message.background = Color::WHITE
              cc.message.editable = false
              cc.message.border = BorderFactory.createEmptyBorder(0, 30, 0, 0)
              ii.message = { :hyperlink => proc do |t, e|
                  if e.event_type.to_s == "ACTIVATED"
                    desktop = Desktop.getDesktop()
                    uri = Java::JavaNet::URI.new(e.url.to_s)
                    desktop.browse(uri)
                  end
                end
              }
            end

            c.header = @header.build
            c.header.background = Color::WHITE

            yield c if block_given?
          end
        end

        def build
          @panel.build(:auto_create_container_gaps => false)
        end
      end

      # Contains the controls and messaging for the PGE page of the wizard.
      class PGEPage
        include_package "javax.swing"
        include_package "java.awt"
        include WizardPage

        def initialize(buttons)
          @global_buttons = buttons

          title = "<html><b>Connect to PG&E</b></html>"
          message  = "Enter your PG&E username and password. If you don't have one,"
          message += "create one first and then enter it below."

          header(title, message) do |c|
            layout = "
                [ username_label | <username_field ]
                [ password_label | <password_field ]
                [ _ | create ]
            "

            @controls = Profligacy::Swing::LEL.new(JPanel, layout) do |cc,ii|
              cc.username_label = JLabel.new "PG&E Username:"
              cc.username_field = JTextField.new
              cc.username_field.maximum_size = Dimension.new(160,14)
              ii.username_field = { :key => method(:validate) }

              cc.password_label = JLabel.new "PG&E Password:"
              cc.password_field = JPasswordField.new
              cc.password_field.maximum_size = Dimension.new(160,14)
              ii.password_field = { :key => method(:validate) }

              cc.create = JButton.new "Create a PG&E Account"
              ii.create = { :action => method(:open_pge_sign_up_flow) }
            end
            c.controls = @controls.build
          end
        end

        # Public: Get the currently set username
        def username
          @controls.username_field.text
        end

        # Public: Get the currently set username
        def password
          @controls.password_field.text
        end

        # Determines whether a user has entered both a username and
        # password. If they have then the next button is enabled.
        #
        # Returns nothing.
        def validate(*ignored_args)
          valid = @controls.password_field.text.size > 0 and @controls.username_field.text.size > 0
          @global_buttons.next.enabled = valid
        end

        # Opens the PG&E sign up flow for a user to create an account online
        # if they haven't already.
        #
        # type  - The symbol representing the name of the event called
        # event - The Java::Awt::Event that was triggered.
        #
        # Returns nothing.
        def open_pge_sign_up_flow(type, event)
          desktop = Desktop.getDesktop()
          uri = Java::JavaNet::URI.new("https://www.pge.com/eum/registration?TARGET=https://www.pge.com/csol")
          desktop.browse(uri)
        end
      end

      class PachubePage
        include_package "javax.swing"
        include_package "java.awt"
        include WizardPage

        def initialize(buttons)
          @buttons = buttons

          title = "<html><b>Connect to Pachube</b></html>"
          message  = "In order to view your power data on Pachube you'll need to create an account."

          header(title, message) do |c|
            layout = "
                [ create ]
                [ api_key_label | <api_key ]
                [ feed_id_label | <feed_id ]
                [ datastream_id_label | <datastream_id ]
            "
            @controls = Profligacy::Swing::LEL.new(JPanel, layout) do |cc,ii|
              cc.create = JButton.new "Create a Pachube Account"
              ii.create = { :action => method(:open_pachube_registration) }
              cc.api_key_label = JLabel.new "Api Key:"
              cc.api_key_field = JTextField.new
              ii.api_key_field = { :key => method(:validate) }
              cc.feed_id_label = JLabel.new "Feed id:"
              cc.feed_id_field = JTextField.new
              ii.feed_id_field = { :key => method(:validate) }
              cc.datastream_id_label = JLabel.new "Datastream Name:"
              cc.datastream_id_field = JTextField.new
              ii.datastream_id_field = { :key => method(:validate) }
            end
            c.controls = @controls.build
          end
        end

        def api_key
          @controls.api_key.text.strip
        end

        def feed_id
          @controls.feed_id.text.strip
        end

        def datastream_id
          @controls.datastream_id.text.strip
        end

        # Opens the Pachube plans page so that users can register
        #
        # Returns nothing.
        def open_pachube_registration(*ignored_args)
            desktop = Desktop.getDesktop()
            uri = Java::JavaNet::URI.new("https://pachube.com/plans")
            desktop.browse(uri)
        end

        # Determines whether a user has entered authorization information from
        # Google.
        #
        # Returns nothing.
        def validate(*ignored_args)
          if api_key.any? && feed_id.any? && datastream_id.any?
            @buttons.next.enabled = true
          end
        end
      end

      class CompletePage
        include_package "javax.swing"
        include_package "java.awt"
        include WizardPage

        def initialize(buttons)
          @buttons = buttons

          title = "<html><b>SmarterMeter Setup Complete</b></html>"
          message =  "SmarterMeter will now run in your taskbar and periodically check for new power data "
          message += "and relay it to Google PowerMeter.<br><br>"
          message += "If you encounter an issue or would like to help improve SmarterMeter visit <a href='http://github.com/mcolyer/smartermeter/'>http://github.com/mcolyer/smatermeter</a>"
          message += "<br><br>Enjoy!"

          header(title, message, false)
        end

        # Enable the next button
        #
        # Returns nothing.
        def validate(*ignored_args)
          @buttons.next.enabled = true
        end
      end
    end
  end
end
