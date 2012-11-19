require 'test_helper'

class OtaEnroll::EnrollTest < ActiveSupport::TestCase
  
  def test_profile_service_payload
    result = OtaEnroll::Enroll.profile_service_payload( "http://my.url.com" )
    data = Plist::parse_xml(result)
    assert_match "http://my.url.com", data['PayloadContent']['URL']
    assert_match "We need to verify you", data['PayloadDescription']
    assert_match "Meinlschmidt profile", data['PayloadDisplayName']
    assert_match "org.meinlschmidt.mobileconfig.profile-service", data['PayloadIdentifier']
    assert_match "Profile Service", data['PayloadType']
    assert ["UDID", "VERSION", "PRODUCT", "MAC_ADDRESS_EN0", "IMEI", "ICCID"].sort == data['PayloadContent']['DeviceAttributes'].sort
  end

  def test_client_cert_configuration_payload
    result = OtaEnroll::Enroll.client_cert_configuration_payload(nil, 'http://my.url.com', 'my icon')
    data = Plist::parse_xml(result)[0]
    data.delete('PayloadUUID')
    assert data == {
        "IsRemovable"=>true, 
        "Label"=>"my icon", 
        "PayloadDescription"=>"WebClip", 
        "PayloadDisplayName"=>"Meinlschmidt", 
        "PayloadIdentifier"=>"org.meinlschmidt.webclip.intranet", 
        "PayloadOrganization"=>"Meinlschmidt", 
        "PayloadType"=>"com.apple.webClip.managed", 
        "PayloadVersion"=>1, 
        "URL"=>"http://my.url.com"
      }
  end

  def test_configuration_payload
    result = OtaEnroll::Enroll.configuration_payload(nil, 'encrypted content')
    data = Plist::parse_xml(result)
    assert_match 'encrypted content', data['EncryptedPayloadContent'].read
    data.delete('EncryptedPayloadContent')
    data.delete('PayloadUUID')
    assert_match (DateTime.now + 1.second).utc.to_s, data['PayloadExpirationDate'].to_s
    data.delete('PayloadExpirationDate')
    assert data == {
        "PayloadDescription"=>"We need to verify you", 
        "PayloadDisplayName"=>"Meinlschmidt profile", 
        "PayloadIdentifier"=>"org.meinlschmidt.enroll", 
        "PayloadOrganization"=>"Meinlschmidt", 
        "PayloadType"=>"Configuration", 
        "PayloadVersion"=>1
      }
  end

  # tests scep_cert_payload as well
  def test_encryption_cert_payload
    challenge = 'challenge'
    url = 'http://my.url.com/scep'
    result = OtaEnroll::Enroll.encryption_cert_payload(nil, challenge, url)
    data = Plist::parse_xml(result)
    data.delete('PayloadUUID')
    data['PayloadContent'][0].delete('PayloadUUID')
    assert data == {
          "PayloadContent"=>[
            {
              "PayloadContent"=>{
                "Challenge"=> challenge, 
                "Key Type"=>"RSA", 
                "Key Usage"=>5, 
                "Keysize"=>1024, 
                "Subject"=>[
                  [["O", "Meinlschmidt"]], 
                  [["CN", "Profile Service"]]
                ], 
                "URL"=> url
              }, 
              "PayloadDescription"=>"Provides device encryption identity", 
              "PayloadDisplayName"=>"Profile Service", 
              "PayloadIdentifier"=>"org.meinlschmidt.encryption-cert-request", 
              "PayloadOrganization"=>"Meinlschmidt", 
              "PayloadType"=>"com.apple.security.scep", 
              #"PayloadUUID"=>"19a0ced4-ae98-4d97-93e8-94eac79debd3", 
              "PayloadVersion"=>1
            }
          ], 
          "PayloadDescription"=>"Enrolls identity for the encrypted profile service", 
          "PayloadDisplayName"=>"Profile Service Enroll", 
          "PayloadIdentifier"=>"org.meinlschmidt.encrypted-profile-service", 
          "PayloadOrganization"=>"Meinlschmidt", 
          "PayloadType"=>"Configuration", 
          #"PayloadUUID"=>"0a579c77-9c51-4d38-a55b-f9cfd257b4f8", 
          "PayloadVersion"=>1
        }
  end

end
