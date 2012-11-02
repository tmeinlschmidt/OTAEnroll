module OtaEnroll

  class Cert

    def self.issue_cert(dn, key, serial, not_before, not_after, extensions, issuer, issuer_key, digest)
      cert = OpenSSL::X509::Certificate.new
      issuer = cert unless issuer
      issuer_key = key unless issuer_key
      cert.version = 2 # FIXME - increment version
      cert.serial = serial
      cert.subject = dn
      cert.issuer = issuer.subject
      cert.public_key = key.public_key
      cert.not_before = not_before
      cert.not_after = not_after
      ef = OpenSSL::X509::ExtensionFactory.new
      ef.subject_certificate = cert
      ef.issuer_certificate = issuer
      extensions.each do |oid, value, critical|
        cert.add_extension(ef.create_extension(oid, value, critical))
      end
      cert.sign(issuer_key, digest)
      cert
    end

    # descrypt response data
    def self.decrypt_request(data)
      p7sign = OpenSSL::PKCS7.new(data)
      store = OpenSSL::X509::Store.new
      p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)

      Plist::parse_xml(p7sign.data)
    end

  end

end
