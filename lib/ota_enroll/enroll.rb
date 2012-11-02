module OtaEnroll

  class Enroll

    # intitial certificate to fetch data from Device
    def self.profile_service_payload(payload_url)
      puts "XXX: profile_service_payload"

      puts "XXX: settings: #{OtaEnroll.settings}"

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
