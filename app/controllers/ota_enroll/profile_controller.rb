require_dependency "ota_enroll/application_controller"

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
      signed_profile = OpenSSL::PKCS7.sign(certs.ssl_cert, certs.ssl_key, configuration, [], OpenSSL::PKCS7::BINARY)

      send_data signed_profile.to_der, content_type: "application/x-apple-aspen-config"
    end

    # here we continue, step #2
    def profile
      device_attributes = OtaEnroll::Cert.decrypt_request(request.body.read)
      data = device_attributes.inject({}){|a,(k,v)| a[k.downcase.to_sym] = v; a}.merge(params)

      url = params[:callback_url]
      query = data.to_query

      redirect_to("#{url}?#{query}", :status => :moved_permanently)
    end
  end
end
