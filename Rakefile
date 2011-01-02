require 'rawr'

namespace :rawr do
  task :prepare do
    dir = File.join(File.dirname(__FILE__), "vendor", "gems")
    FileUtils.rm_rf(dir)
    FileUtils.mkdir_p(dir)
    ["nokogiri", "mechanize"].each do |gem|
      `gem unpack -t "#{dir}" #{gem}`
    end

    # Rawr can't handle folders with dashes in the name, so we'll remove the
    # version numbers from the gems.
    Dir.glob(File.join(dir, "*-*")).each do |gem|
      no_version = File.basename(gem).split("-")[0]
      FileUtils.mv(gem, File.join(dir, no_version))
    end
  end
end
