require 'logger'
require 'profligacy/swing'
require 'profligacy/lel'

module SmarterMeter
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
        tray_icon = TrayIcon.new(image, "Smartermeter", popup)
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
        SettingsWindow.new do |config|
          yield config
        end
      end
    end

    class SettingsWindow
      include_package "javax.swing"

      def initialize(&block)
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

        @frame = @ui.build(:args => "Smartermeter Settings")
        @frame.defaultCloseOperation = JFrame::DISPOSE_ON_CLOSE
      end
    end

    class LogWindow
      include_package "javax.swing"

      LogFile = File.expand_path("~/.smartermeter.log")

      def initialize(&block)
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

        @frame = @ui.build(:args => "Smartermeter Log")
        @frame.defaultCloseOperation = JFrame::DISPOSE_ON_CLOSE
      end
    end
  end
end
