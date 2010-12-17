Smartermeter - the smarter way to read your PGE SmartMeter
=========================================================

So I have PGE SmartMeter and I like playing with data. However I didn't really
want to jump through 37 hoops to see the data on PG&E's website. So I made
this.

While making this library I discovered that PG&E doesn't even manage the
software for the energy reporting. It's all done by energyguide.com. Not
terribly useful but an interesting piece of trivia.

What you need
-------------

* ruby >= 1.8.6
* librmagick-ruby

Getting Started
---------------

    git clone git://github.com/mcolyer/smartermeter.git
    cd smartermeter
    bundle install
    bundle exec ruby bin/run.rb USERNAME PASSWORD (MM/DD/YYYY)
    (This should print out the CSV data from yesterday)

Related Projects
----------------

* [PG&E to Google Power Meter](http://gitorious.org/pge-to-google-powermeter) -
  Takes the output from bin/run.rb and uploads it to Google Power meter.

Questions
---------

* How much lag is there?

  It'll show you the last full day's worth of data. The PGE website claims that
  data becomes available around 3-10pm on the following day.

* How long is data saved for?

  I don't know, if you know tell me.

* How can I help?

  Make sure it works, make cool things with it or send me git pull requests.
