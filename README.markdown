# Serial Port Scanner Demo

This is the demo Ruby on Rails application running on torquebox that shows how to push messages from a Honeywell bar code scanner configured to run as a serial device.
Note that it has only been tested with a Vuquest 3310g.

## How to install

1. Read the slides
2. Install Java 1.7 and JRuby
3. Plug in your scanner. Note, that it needs to be configured to run as a serial device. On OS X, it should show up as something like /dev/tty.usbmodem1421. On Linux, it'll be something like /dev/usbACM0.
4. Pull down the repository. Then run the following:

```
bundle install
torquebox deploy
torquebox run
```

You can now point your browser to http://localhost:8080

## Licensing

The included jssc.jar is licensed under the LGPL license. More details about this project can be found here: https://code.google.com/p/java-simple-serial-connector/

The rest is licensed under the MIT license. See license.txt.
