require 'test_helper'

class OtaEnroll::ToolsTest < ActiveSupport::TestCase

  def test_tools
    certs = OtaEnroll::Tools.new
    assert certs.ssl_key
    assert certs.ssl_cert
    assert certs.ra_key
    assert certs.ra_cert
    assert certs.root_key
    assert certs.root_cert
  end

  def test_local_ip
    assert OtaEnroll::Tools.local_ip.match /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
  end

end
