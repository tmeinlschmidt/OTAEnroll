module OtaEnroll

  class Enroll

    # intitial certificate to fetch data from Device
    def self.profile_service_payload(payload_url)
      payload = general_payload

      payload['PayloadType'] = "Profile Service" # do not modify
      payload['PayloadIdentifier'] = "#{OtaEnroll.settings.identifier}.mobileconfig.profile-service"

      # strings that show up in UI, customisable
      payload['PayloadDisplayName'] = OtaEnroll.settings.display_name
      payload['PayloadDescription'] = OtaEnroll.settings.description

      payload_content = {}
      payload_content['URL'] = payload_url

      # what we need to fetch
      payload_content['DeviceAttributes'] = [
          "UDID",
          "VERSION",
          "PRODUCT",
          "MAC_ADDRESS_EN0",
          "IMEI",
          "ICCID"
        ]

      payload['PayloadContent'] = payload_content
      Plist::Emit.dump(payload)
    end
    
    # generate content of configuration payload
    def self.client_cert_configuration_payload(request, url, name)
      webclip_payload = general_payload

      webclip_payload['PayloadIdentifier'] = "#{OtaEnroll.settings.identifier}.webclip.intranet"
      webclip_payload['PayloadType'] = "com.apple.webClip.managed" # do not modify

      # strings that show up in UI, customisable
      webclip_payload['PayloadDisplayName'] = OtaEnroll.settings.organization
      webclip_payload['PayloadDescription'] = "WebClip"

      # allow user to remove webclip
      webclip_payload['IsRemovable'] = true

      # the link
      webclip_payload['Label'] = name
      webclip_payload['URL'] = url

      # emit webclip only
      Plist::Emit.dump([webclip_payload])
    end
    
    # wraps configurarion content, will expire immediately, thus not visible then in certificates
    def self.configuration_payload(request, encrypted_content)
      payload = general_payload
      payload['PayloadIdentifier'] = "#{OtaEnroll.settings.identifier}.enroll"
      payload['PayloadType'] = "Configuration" # do not modify

      # strings that show up in UI, customisable
      payload['PayloadDisplayName'] = OtaEnroll.settings.display_name
      payload['PayloadDescription'] = OtaEnroll.settings.description
      payload['PayloadExpirationDate'] = Time.now + 1.day

      payload['EncryptedPayloadContent'] = StringIO.new(encrypted_content)
      Plist::Emit.dump(payload)
    end
    
    def self.encryption_cert_payload(request, challenge, scep_url)
      payload = general_payload

      payload['PayloadIdentifier'] = "#{OtaEnroll.settings.identifier}.encrypted-profile-service"
      payload['PayloadType'] = "Configuration" # do not modify

      # strings that show up in UI, customisable
      # FIXME: configuration
      payload['PayloadDisplayName'] = "Profile Service Enroll"
      payload['PayloadDescription'] = "Enrolls identity for the encrypted profile service"

      payload['PayloadContent'] = [scep_cert_payload(request, "Profile Service", challenge, scep_url)];
      Plist::Emit.dump(payload)
    end
    
    def self.scep_cert_payload(request, purpose, challenge, scep_url)
      payload = general_payload

      payload['PayloadIdentifier'] = "#{OtaEnroll.settings.identifier}.encryption-cert-request"
      payload['PayloadType'] = "com.apple.security.scep" # do not modify

      # strings that show up in UI, customisable
      payload['PayloadDisplayName'] = purpose
      payload['PayloadDescription'] = "Provides device encryption identity"

      payload_content = {}
      payload_content['URL'] = scep_url
      #payload_content['Name'] = "" 
      payload_content['Subject'] = [ 
        [ [ "O", OtaEnroll.settings.organization ] ], 
        [ [ "CN", purpose ] ] 
      ];
      payload_content['Challenge'] = challenge if challenge.present?
      
      payload_content['Keysize'] = 1024 #1024
      payload_content['Key Type'] = "RSA"
      payload_content['Key Usage'] = 5 # digital signature (1) | key encipherment (4)

      # Disabled until the following is fixed: <rdar://problem/7172187> SCEP various fixes
      #certs = OtaEnroll::Tools.new
      #payload_content['CAFingerprint'] = StringIO.new(OpenSSL::Digest::SHA1.new(certs.root_cert.to_der).digest)

      payload['PayloadContent'] = payload_content
      payload
    end

    private

    def self.general_payload
      payload = {}
      payload['PayloadVersion'] = 1 # do not modify
      payload['PayloadUUID'] = ::UUIDTools::UUID.random_create().to_s # should be unique

      # string that show up in UI, customisable
      payload['PayloadOrganization'] = OtaEnroll.settings.organization
      payload
    end

  end

end
