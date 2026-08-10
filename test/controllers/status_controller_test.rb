require "test_helper"

class StatusControllerTest < ActionDispatch::IntegrationTest
  test "tanpa parameter email hanya menampilkan form pencarian" do
    get status_url

    assert_response :success
    assert_select "input[name=?]", "email"
    assert_no_match "Tidak ada pendaftaran", response.body
  end

  test "email kosong diperlakukan sama seperti tanpa parameter" do
    get status_url, params: { email: "   " }

    assert_response :success
    assert_no_match "Tidak ada pendaftaran", response.body
  end

  test "pendaftar yang belum lunas melihat data dan keterangan belum lunas" do
    registration = registrations(:budi)
    assert_not registration.paid, "prasyarat: fixture budi harus belum lunas"

    get status_url, params: { email: registration.email }

    assert_response :success
    assert_match registration.name, response.body
    assert_match registration.category.name, response.body
    assert_match "##{registration.id}", response.body
    assert_match "Belum lunas", response.body
  end

  test "pendaftar yang sudah lunas melihat keterangan lunas" do
    registration = registrations(:siti)
    assert registration.paid, "prasyarat: fixture siti harus lunas"

    get status_url, params: { email: registration.email }

    assert_response :success
    assert_match "Lunas", response.body
    assert_no_match "Belum lunas", response.body
  end

  test "pencarian tidak peka huruf besar kecil dan spasi berlebih" do
    get status_url, params: { email: "  BUDI@EXAMPLE.COM  " }

    assert_response :success
    assert_match registrations(:budi).name, response.body
  end

  test "email yang tidak terdaftar menampilkan pesan ramah" do
    get status_url, params: { email: "tidakada@example.com" }

    assert_response :success
    assert_match "Tidak ada pendaftaran", response.body
  end

  test "hasil tidak menampilkan nomor ponsel pendaftar" do
    get status_url, params: { email: registrations(:budi).email }

    assert_no_match registrations(:budi).phone, response.body
  end
end
