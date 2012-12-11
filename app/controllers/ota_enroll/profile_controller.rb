require_dependency "ota_enroll/application_controller"
require 'net/http'

module OtaEnroll

  class ProfileController < ApplicationController

    # gives CA profile to the user
    def ca
      certs = OtaEnroll::Tools.new
      send_data certs.root_cert.to_der, type: 'application/x-x509-ca-cert' and return
    end

    # enroll configuration profile - BEGIN of process, step #1
    def enroll
      certs = OtaEnroll::Tools.new
      configuration = OtaEnroll::Enroll.profile_service_payload(profile_url(params))
      sign_certs = []
      sign_certs = [certs.sign_interm_cert] if certs.sign_interm_cert.present?
      
      logger.info "enroll configuration: #{configuration} #{sign_certs.inspect}" if debug?
      
      signed_profile = OpenSSL::PKCS7.sign(certs.ssl_cert, certs.ssl_key, configuration, sign_certs, OpenSSL::PKCS7::BINARY)

      send_data signed_profile.to_der, content_type: "application/x-apple-aspen-config"
    end

    # here we continue, step #2
    def profile
      p7sign, device_attributes = OtaEnroll::Cert.decrypt_request(request.body.read)
      icon_url = params.delete(:icon_url)
      icon_label = params.delete(:icon_label)
      callback_url, extra_data = (params.delete(:callback_url)||'').split(/\?/)
      
      # parse callback_url extra data
      extra_data = extra_data.split(/&/).inject({}){|k, v| c=v.split(/=/);k[c[0]] = c[1];k} rescue {}

      data = device_attributes.inject({}){|a,(k,v)| a[k.downcase.to_sym] = v; a}.merge(params.reject{|k,v| ['controller','action'].include?(k.to_s)})
      data.merge!(extra_data)

      # do pingback with values and callback_secret
      query = calculate_secret(data, OtaEnroll.settings.callback_secret)
      logger.info "callback: #{query}" if debug?
      Net::HTTP.get(URI.parse("#{callback_url}?#{query}"))

      certs = OtaEnroll::Tools.new
      # create payload

      logger.info "profile signers \"#{p7sign.signers[0].issuer.to_s}\" == \"#{certs.root_cert.subject.to_s}\"" if debug?
      
      if (p7sign.signers[0].issuer.to_s == certs.root_cert.subject.to_s)
        payload = OtaEnroll::Enroll.client_cert_configuration_payload(request, icon_url, icon_label)
        encrypted_profile = OpenSSL::PKCS7.encrypt(p7sign.certificates,
          payload, OpenSSL::Cipher::Cipher::new("des-ede3-cbc"), OpenSSL::PKCS7::BINARY)
        configuration = OtaEnroll::Enroll.configuration_payload(request, encrypted_profile.to_der)
      else
        configuration = OtaEnroll::Enroll.encryption_cert_payload(request, "", scep_url)
      end

      logger.info "profile configuration: #{configuration}" if debug?
      
      sign_certs = []
      sign_certs = [certs.sign_interm_cert] if certs.sign_interm_cert.present?
      
      signed_profile = OpenSSL::PKCS7.sign(certs.ssl_cert, certs.ssl_key, configuration, sign_certs, OpenSSL::PKCS7::BINARY)
      send_data signed_profile.to_der, content_type: "application/x-apple-aspen-config"
    end
    
    def scep
      certs = OtaEnroll::Tools.new

      if params['operation'] == 'GetCACert'
        scep_certs = OpenSSL::PKCS7.new()
        scep_certs.type = "signed"
        scep_certs.certificates = [certs.root_cert, certs.ra_cert]
        scep_certs.certificates = [certs.root_cert, certs.server_interm_cert, certs.ra_cert] if certs.server_interm_cert.present?

        logger.info "scep certificates #{scep_certs.certificates.inspect}" if debug?

        send_data scep_certs.to_der, content_type: "application/x-x509-ca-ra-cert" and return
      end

      if params['operation'] == 'GetCACaps'
        render inline: "POSTPKIOperation\nSHA-1\nDES3\n", layout: false and return
      end

      if params['operation'] == 'PKIOperation'
        # PKIOp
        p7sign = OpenSSL::PKCS7.new(request.body.read)
        store = OpenSSL::X509::Store.new
        p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)
        signers = p7sign.signers
        p7enc = OpenSSL::PKCS7.new(p7sign.data)
        csr = p7enc.decrypt(certs.ra_key, certs.ra_cert)
        cert = OtaEnroll::Cert.issueCert(csr, 1)
        degenerate_pkcs7 = OpenSSL::PKCS7.new()
        degenerate_pkcs7.type="signed"
        degenerate_pkcs7.certificates=[cert]
        enc_cert = OpenSSL::PKCS7.encrypt(p7sign.certificates, degenerate_pkcs7.to_der,
        OpenSSL::Cipher::Cipher::new("des-ede3-cbc"), OpenSSL::PKCS7::BINARY)
        reply = OpenSSL::PKCS7.sign(certs.ra_cert, certs.ra_key, enc_cert.to_der, [], OpenSSL::PKCS7::BINARY)
        send_data reply.to_der, content_type: "application/x-pki-message" and return
      end
    end

    private
 
    def debug?
      OtaEnroll.settings.debug == true
    end

    # calculate secret - SHA1 of sorted keys + secret
    def calculate_secret(data, secret)
      data = data.sort{|a,b| a.to_s <=> b.to_s}.inject({}){|a,(k,v)| a[k.downcase.to_sym] = v; a}
      calculated_secret = Digest::SHA1.hexdigest(data.to_query + secret)
      data.merge(:sign => calculated_secret).to_query
    end

  end # class

end
