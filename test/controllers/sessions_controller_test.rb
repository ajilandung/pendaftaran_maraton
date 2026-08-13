require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "halaman login menampilkan field kata sandi" do
    get login_url

    assert_response :success
    assert_select "input[type=password][name=password]"
  end

  test "kata sandi benar membuka panel panitia" do
    post login_url, params: { password: admin_password }

    assert_redirected_to admin_registrations_path

    follow_redirect!
    assert_response :success
  end

  test "kata sandi salah tidak membuka panel panitia" do
    post login_url, params: { password: "salah" }

    assert_response :unprocessable_entity
    assert_match "Kata sandi salah", response.body

    get admin_registrations_url
    assert_redirected_to login_path
  end

  test "kata sandi kosong ditolak" do
    post login_url, params: { password: "" }

    assert_response :unprocessable_entity
  end

  test "panitia yang sudah masuk dialihkan dari halaman login" do
    sign_in_as_admin

    get login_url

    assert_redirected_to admin_registrations_path
  end

  test "keluar mengakhiri sesi panitia" do
    sign_in_as_admin

    delete logout_url

    assert_redirected_to root_path

    get admin_registrations_url
    assert_redirected_to login_path
  end
end
