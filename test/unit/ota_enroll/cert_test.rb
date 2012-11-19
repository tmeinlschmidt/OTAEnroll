require 'test_helper'

class OtaEnroll::CertTest < ActiveSupport::TestCase
  
  def test_decrypt_request
    data = read_fixture('1353278848-profile-profile')
    sign, device_data = OtaEnroll::Cert.decrypt_request(data)
    assert_equal device_data, { "IMEI"=>"01 335200 242816 7", 
                                "PRODUCT"=>"iPhone5,2", 
                                "UDID"=>"ea750fdbc619ca406d066d7ed158d54483fc382f", 
                                "VERSION"=>"10A525"}
  end

end
