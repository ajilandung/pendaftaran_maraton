require "test_helper"

class Admin::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "tanpa kredensial halaman panitia ditolak" do
    get admin_registrations_url

    assert_response :unauthorized
  end

  test "dengan kredensial benar daftar pendaftar tampil" do
    get admin_registrations_url, headers: auth_headers

    assert_response :success
    assert_match registrations(:budi).name, response.body
    assert_match registrations(:siti).name, response.body
  end

  test "sisa kuota tiap kategori tampil" do
    get admin_registrations_url, headers: auth_headers

    assert_response :success
    assert_match categories(:five_k).name, response.body
    assert_match "Sisa #{categories(:five_k).remaining_quota}", response.body
  end

  test "menandai lunas mengubah status pendaftaran" do
    registration = registrations(:budi)
    assert_not registration.paid

    patch mark_paid_admin_registration_url(registration), headers: auth_headers

    assert_redirected_to admin_registrations_path
    assert registration.reload.paid
  end

  test "membatalkan tanda lunas mengembalikan status belum lunas" do
    registration = registrations(:siti)
    assert registration.paid

    patch mark_unpaid_admin_registration_url(registration), headers: auth_headers

    assert_redirected_to admin_registrations_path
    assert_not registration.reload.paid
  end

  test "menandai lunas tetap berhasil pada kategori yang sudah penuh" do
    registration = registrations(:andi)
    assert registration.category.full?, "prasyarat: kategori fixture harus penuh"

    patch mark_paid_admin_registration_url(registration), headers: auth_headers

    assert_redirected_to admin_registrations_path
    assert registration.reload.paid
  end

  test "menghapus pendaftaran mengurangi jumlah pendaftaran" do
    assert_difference "Registration.count", -1 do
      delete admin_registration_url(registrations(:budi)), headers: auth_headers
    end

    assert_redirected_to admin_registrations_path
  end

  test "menghapus pendaftaran membebaskan slot kategorinya" do
    category = categories(:fun_run)
    assert category.full?

    delete admin_registration_url(registrations(:andi)), headers: auth_headers

    assert_equal 1, category.reload.remaining_quota
  end

  test "tanpa kredensial penghapusan tidak terjadi" do
    assert_no_difference "Registration.count" do
      delete admin_registration_url(registrations(:budi))
    end

    assert_response :unauthorized
  end

  private
    def auth_headers
      {
        "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(
          "admin", Rails.application.credentials.admin_password
        )
      }
    end
end
