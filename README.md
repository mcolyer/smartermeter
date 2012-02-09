SmarterMeter - the smarter way to read your PG&E SmartMeter
=========================================================

So I have PG&E SmartMeter and I like playing with data. However I didn't
really want to jump through 37 hoops to see the data on PG&E's website.
So I made this.

While making this library I discovered that PG&E doesn't even manage the
software for the energy reporting. It's all done by OPower, not terribly
useful but an interesting piece of trivia.

Getting Started
---------------

    gem install smartermeter
    smartermeter

Manipulating the data
---------------------

After you've successfully downloaded one set of data, you should be able
to manipulate it using ruby like so:

    require 'rubygems'
    require 'smartermeter'

    config = YAML.load_file(File.expand_path("~/.smartermeter"))
    csv_file = Dir.glob(File.join(config[:data_dir], "*.csv")).last

    samples = SmarterMeter::Samples.parse_espi(csv_file)
    kwh_used = samples.total_kwh
    api = SmarterMeter::Services::BrighterPlanet.new
    puts api.calculate_kg_carbon(kwh_used)

For futher information see the [API docs][rdoc]

Pachube
-----------------

Once you've configured SmarterMeter once, you might want to use it with
Pachube, so you can visualize the results.

1. Visit http://pachube.com and sign up for an account.
1. Create a feed and a datastream.
1. Copy the feed id (the last item in a feed url like 123 in
   https://pachube.com/feeds/123) and the datastream id (which is the
   name that you enter)
1. Then append the following to your ~/.smartermeter file to
automatically upload data as it's retrieved from PG&E.

```
    :transport: :pachube
    :pachube:
        :api_key: "your-api-key"
        :feed_id: "your-feed-id"
        :datastream_id: "your-datastream-id"
```

To Build the Windows Installer
--------

In order to build the self contained binaries, you'll need Java 1.6 and
(NSIS)[1], both of which are available as packages in Ubuntu.

    apt-get install nsis sun-java6-jre
    git clone git://github.com/mcolyer/smartermeter.git
    cd smartermeter
    bundle install --path vendor/gems
    rake package

The installer will be generated in pkg/

Questions
---------

* How much lag is there?

  It'll show you the last full day's worth of data. The PGE website
  claims that data becomes available around 3-10pm on the following day.
  However my experience says that it's sometimes available earlier.

* How long is data saved for?

  I don't know. If you know tell me.

* How can I help?

  Make sure it works, make cool things with it or send me git pull
  requests.

Sponsorship
-----------

I would like to thank [Brighter Planet][2] for including SmarterMeter as
part of their [Fellowship Program][3]

[1]: http://nsis.sourceforge.net/
[2]: http://brighterplanet.com/
[3]: http://brighterplanet.github.com/fellowship.html
[rdoc]: http://rdoc.info/github/mcolyer/smartermeter/master/frames
