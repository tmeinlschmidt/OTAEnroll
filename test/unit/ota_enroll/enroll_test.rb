require 'test_helper'

class OtaEnroll::EnrollTest < ActiveSupport::TestCase
  def test_profile_service_payload
    result = OtaEnroll::Enroll.profile_service_payload( "http://my.url.com" )

    puts result
  end
end
