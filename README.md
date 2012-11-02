# OtaEnroll

Fetches UDID and other info from iOS device using OTA configuration.

## Installation

Add this line to your application's Gemfile:

    gem 'OtaEnroll'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install OtaEnroll

## Usage

1. create ``support`` dir
2. run ``rake cert:ca``, ``rake cert:ra`` and ``rake cert:ssl``
3. create ``config/ota_enroll.yml`` - see sample bellow

call ``/enroll/enroll?userid=my_userid&url=http://where-i-want.redirect.to``

after successfull OTA you'll get request with all the info, including your userid - imei. udid, osversion

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
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
= OtaEnroll

This project rocks and uses MIT-LICENSE.