# OtaEnroll

Fetches UDID and other info from iOS device using OTA configuration.

## Installation

Add this line to your application's Gemfile:

    gem 'ota_enroll'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install OtaEnroll

## Usage

1. create ``support`` dir
2. run ``rake cert:ca``, ``rake cert:ra`` and ``rake cert:ssl``
3. create ``config/ota_enroll.yml`` - see sample bellow
4. add ``mount OtaEnroll::Engine => "/ota_enroll", :as => "ota_enroll_engine"`` to your ``config/routes.rb``
5. add to your view ``ota_enroll_engine.enroll_path( :callback_url => callback_url, :icon_url => icon_url, :icon_label => 'label' )``

### Generate Certifies in console ###

    openssl genrsa -out enroll.appbounty.net.key 1024
    openssl req -new -key enroll.appbounty.net.key -out enroll.appbounty.net.csr
    openssl x509 -req -days 365 -in enroll.appbounty.net.csr -signkey enroll.appbounty.net.key -out enroll.appbounty.net.crt

Or follow instructions here: http://www.perturb.org/display/754_Apache_self_signed_certificate_HOWTO.html

    openssl genrsa -out ca.key 4096
    openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
    openssl genrsa -out server.key 4096
    openssl req -new -key server.key -out server.csr
    openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

### sample config

```
development:
  ca_crt: /support/ca_cert.pem
  ca_key: /support/ca_private.pem
  ssl_key: /support/ssl_private.pem
  ssl_crt: /support/ssl_cert.pem
  # ra_crt: /support/ra_cert.pem
  # ra_key: /support/ra_private.pem
  server: https://192.168.1.129
  organization: Meinlschmidt
  identifier: org.meinlschmidt
  display_name: Meinlschmidt profile
  description: We need to verify you
  callback_secret: callback secret key
```

### calling enroll

call with following params

* ``callback_url`` - what to call back with device parameters, eg: ``http://my.server.com/callback?uid=13123``
* ``icon_url`` - icon URL eg. ``http://my.server.com/welcome/13123``
* ``icon_label`` - what to display as icon link, eg. ``MyServer``

### redirecting

on the page you're calling enroll link, please create following javascript:

```
<script content="text/javascript">
  var old = new Date().getTime();;

  var interval = setInterval(function() {
    var newtime = new Date().getTime();
    if ((newtime - old)>550) {
      stopInterval(interval);
      // here you can redirect
      // window.location.href = "....";
    }
    document.getElementById('counter2').innerHTML = (newtime - old);
    old = newtime;
  }, 500);
</script>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
= OtaEnroll

This project rocks and uses MIT-LICENSE.
