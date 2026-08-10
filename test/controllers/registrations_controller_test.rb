require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "form pendaftaran menampilkan seluruh field wajib" do
    get new_registration_url

    assert_response :success
    assert_select "select[name=?]", "registration[category_id]"
    assert_select "input[name=?]", "registration[name]"
    assert_select "input[name=?]", "registration[email]"
    assert_select "input[name=?]", "registration[phone]"
    assert_select "select[name=?]", "registration[jersey_size]"
  end

  test "daftar pilihan kategori tidak memuat kategori yang penuh" do
    get new_registration_url

    assert_select "select[name=?]", "registration[category_id]" do
      assert_select "option[value=?]", categories(:five_k).id.to_s
      assert_select "option[value=?]", categories(:fun_run).id.to_s, count: 0
    end
  end

  test "data valid menambah satu pendaftaran dan mengalihkan ke halaman sukses" do
    assert_difference "Registration.count", 1 do
      post registrations_url, params: { registration: valid_attributes }
    end

    assert_redirected_to registration_url(Registration.last)
  end

  test "halaman sukses menampilkan nomor pendaftaran yang sama dengan id" do
    post registrations_url, params: { registration: valid_attributes }
    registration = Registration.last

    follow_redirect!

    assert_response :success
    assert_match "##{registration.id}", response.body
    assert_match registration.name, response.body
  end

  test "halaman sukses tidak menampilkan email pendaftar" do
    post registrations_url, params: { registration: valid_attributes }
    follow_redirect!

    assert_no_match valid_attributes[:email], response.body
  end

  test "pengiriman tanpa nama tidak menambah pendaftaran dan menampilkan pesan kesalahan" do
    assert_no_difference "Registration.count" do
      post registrations_url, params: { registration: valid_attributes.merge(name: "") }
    end

    assert_response :unprocessable_entity
    assert_match "can&#39;t be blank", response.body
  end

  test "email yang sudah terdaftar ditolak" do
    assert_no_difference "Registration.count" do
      post registrations_url, params: { registration: valid_attributes.merge(email: registrations(:budi).email) }
    end

    assert_response :unprocessable_entity
    assert_match "has already been taken", response.body
  end

  test "pendaftaran ke kategori penuh ditolak" do
    assert_no_difference "Registration.count" do
      post registrations_url, params: { registration: valid_attributes.merge(category_id: categories(:fun_run).id) }
    end

    assert_response :unprocessable_entity
    assert_match "sudah penuh", response.body
  end

  private
    def valid_attributes
      {
        name: "Rina Kusuma",
        email: "rina@example.com",
        phone: "081233334444",
        jersey_size: "L",
        category_id: categories(:five_k).id
      }
    end
end
