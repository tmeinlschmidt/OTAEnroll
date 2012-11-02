require 'test_helper'

module OtaEnroll
  class ProfileControllerTest < ActionController::TestCase
    tests OtaEnroll::ProfileController

    def test_should_ca
      puts "XXX: @controller:#{@controller.respond_to? :ca}"
      get :ca
      assert_response :success
    end

    test "should get enroll" do
      get :enroll
      assert_response :success
    end

    test "should get profile" do
      get :profile
      assert_response :success
    end

  end
end
