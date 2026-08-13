require "test_helper"

class Admin::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "tanpa login halaman panitia dialihkan ke halaman login" do
    get admin_registrations_url

    assert_redirected_to login_path
  end

  test "setelah login daftar pendaftar tampil" do
    sign_in_as_admin

    get admin_registrations_url

    assert_response :success
    assert_match registrations(:budi).name, response.body
    assert_match registrations(:siti).name, response.body
  end

  test "sisa kuota tiap kategori tampil" do
    sign_in_as_admin

    get admin_registrations_url

    assert_response :success
    assert_match categories(:five_k).name, response.body
    assert_match "Sisa #{categories(:five_k).remaining_quota}", response.body
  end

  test "menandai lunas mengubah status pendaftaran" do
    sign_in_as_admin
    registration = registrations(:budi)
    assert_not registration.paid

    patch mark_paid_admin_registration_url(registration)

    assert_redirected_to admin_registrations_path
    assert registration.reload.paid
  end

  test "membatalkan tanda lunas mengembalikan status belum lunas" do
    sign_in_as_admin
    registration = registrations(:siti)
    assert registration.paid

    patch mark_unpaid_admin_registration_url(registration)

    assert_redirected_to admin_registrations_path
    assert_not registration.reload.paid
  end

  test "menandai lunas tetap berhasil pada kategori yang sudah penuh" do
    sign_in_as_admin
    registration = registrations(:andi)
    assert registration.category.full?, "prasyarat: kategori fixture harus penuh"

    patch mark_paid_admin_registration_url(registration)

    assert_redirected_to admin_registrations_path
    assert registration.reload.paid
  end

  test "menghapus pendaftaran mengurangi jumlah pendaftaran" do
    sign_in_as_admin

    assert_difference "Registration.count", -1 do
      delete admin_registration_url(registrations(:budi))
    end

    assert_redirected_to admin_registrations_path
  end

  test "menghapus pendaftaran membebaskan slot kategorinya" do
    sign_in_as_admin
    category = categories(:fun_run)
    assert category.full?

    delete admin_registration_url(registrations(:andi))

    assert_equal 1, category.reload.remaining_quota
  end

  test "tanpa login penghapusan tidak terjadi" do
    assert_no_difference "Registration.count" do
      delete admin_registration_url(registrations(:budi))
    end

    assert_redirected_to login_path
  end

  test "tanpa login penandaan lunas tidak terjadi" do
    registration = registrations(:budi)

    patch mark_paid_admin_registration_url(registration)

    assert_redirected_to login_path
    assert_not registration.reload.paid
  end
end
