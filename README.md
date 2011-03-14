Smartermeter - the smarter way to read your PGE SmartMeter
=========================================================

So I have PGE SmartMeter and I like playing with data. However I didn't really
want to jump through 37 hoops to see the data on PG&E's website. So I made
this.

While making this library I discovered that PG&E doesn't even manage the
software for the energy reporting. It's all done by energyguide.com. Not
terribly useful but an interesting piece of trivia.

Getting Started
---------------

    gem install smartermeter
    smartermeter

Google PowerMeter
-----------------

Once you've configured smartermeter once, you might want to use it with Google
PowerMeter.

1. Visit: https://www.google.com/powermeter/device/activate?mfg=Ruby&model=SmarterMeter&did=PGE&dvars=1
1. Then sign in with your desired Google Account.
1. Follow the directions on screen.
1. On the final screen copy the entire "authInfo" into your favorite editor.
   Pull out the "token" and the "path" from the string.
1. Take the "path" you collected previously and append ".d1" to the end of it.
1. Then append the following to your ~/.smartermeter file to
   automatically upload data as it's retrieved from PG&E.

       :transport: :google_powermeter
       :google_powermeter:
         :token: "your-token"
         :variable: "your-path-with.d1-appended"

To Build the Windows Installer
--------

In order to build the self contained binaries, you'll need Java 1.6 and
(NSIS)[1], both are available as packages in Ubuntu.

    git clone git://github.com/mcolyer/smartermeter.git
    cd smartermeter
    bundle install --path vendor/gems --without test
    rake package

The installer will be generated in pkg/

Questions
---------

* How much lag is there?

  It'll show you the last full day's worth of data. The PGE website claims that
  data becomes available around 3-10pm on the following day. However my
  experience says that it's sometimes available earlier.

* How long is data saved for?

  I don't know. If you know tell me.

* How can I help?

  Make sure it works, make cool things with it or send me git pull requests.

Sponsorship
-----------

I would like to thank [Brighter Planet][2] for including SmarterMeter as part
of their [Fellowship Program][3]

[1]: http://nsis.sourceforge.net/
[2]: http://brighterplanet.com/
[2]: http://brighterplanet.github.com/fellowship.html
