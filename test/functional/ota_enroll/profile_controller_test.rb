require 'test_helper'
require 'fakeweb'

class ApplicationControllerTest < ActionController::TestCase
  tests OtaEnroll::ProfileController
  
  def setup
    @routes = OtaEnroll::Engine.routes
  end

  def test_should_ca
    get :ca
    assert_response :success
  end

  test "should get enroll" do
    get :enroll
    assert_response :success
    assert_equal 'application/x-apple-aspen-config', response.content_type
  end

  # we send mocked response from real iPhone, then test callback
  test "should get profile" do
    params = {action: 'enroll', callback_url: 'http://192.168.1.129/callback?uid=znouza', icon_label: 'my site', icon_url: 'http://www.cesnet.cz'}
    FakeWeb.allow_net_connect = 'http://192.168.1.129'
    FakeWeb.register_uri(:get, 'http://192.168.1.129/callback?uid=znouza?imei=01+335200+242816+7&product=iPhone5%2C2&sign=63543d1643344c147cbf100279200e1b559ad1cc&udid=ea750fdbc619ca406d066d7ed158d54483fc382f&version=10A525', body: 'OK', status: [200, 'OK'])
    raw_post :profile, params, read_fixture('1353278848-profile-profile')
    assert_response :success
    last_request = FakeWeb.last_request
    assert_equal 'GET', last_request.method
    assert_equal '/callback?uid=znouza?imei=01+335200+242816+7&product=iPhone5%2C2&sign=63543d1643344c147cbf100279200e1b559ad1cc&udid=ea750fdbc619ca406d066d7ed158d54483fc382f&version=10A525', last_request.path
    assert_equal 'application/x-apple-aspen-config', response.content_type
  end

  test "should get scep GetCACert" do
    get :scep, {operation: 'GetCACert'}
    assert_response :success
    assert_equal "application/x-x509-ca-ra-cert", response.content_type
  end

  test "should get scep GetCACaps" do
    get :scep, {operation: 'GetCACaps'}
    assert_response :success
    assert_equal "POSTPKIOperation\nSHA-1\nDES3\n", response.body
  end

  test "should get scep PKIOperation" do
    certs = OtaEnroll::Tools.new
    raw_post :scep, {operation: 'PKIOperation'}, read_fixture('1353281987-profile-scep')
    assert_response :success
    pkcs7 = OpenSSL::PKCS7.new(response.body)
    assert_equal "/O=None/CN=Meinlschmidt CA", "#{pkcs7.signers[0].issuer}"
    assert_equal "application/x-pki-message", response.content_type
  end

end
