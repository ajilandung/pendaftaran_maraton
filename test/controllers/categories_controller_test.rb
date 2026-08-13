require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "halaman utama menampilkan seluruh kategori" do
    get root_url

    assert_response :success
    assert_select "h3", text: categories(:five_k).name
    assert_select "h3", text: categories(:ten_k).name
    assert_select "h3", text: categories(:fun_run).name
  end

  test "kategori yang masih punya sisa menampilkan angka sisa kuotanya" do
    get root_url

    assert_response :success
    assert_select "article", text: /Sisa/
    assert_match categories(:five_k).remaining_quota.to_s, response.body
  end

  test "kategori penuh ditandai penuh" do
    assert categories(:fun_run).full?, "prasyarat: fixture fun_run harus penuh"

    get root_url

    assert_select "article", text: /Kuota penuh/
  end

  test "kategori penuh tidak menampilkan tautan pendaftaran" do
    get root_url

    assert_select "a[href=?]", new_registration_path(category_id: categories(:fun_run).id), count: 0
  end

  test "kategori yang masih tersedia menampilkan tautan pendaftaran" do
    get root_url

    assert_select "a[href=?]", new_registration_path(category_id: categories(:five_k).id)
  end

  test "halaman utama menampilkan tautan login panitia" do
    get root_url

    assert_select "a[href=?]", login_path, text: "Login panitia"
  end

  test "panitia yang sudah masuk melihat tautan menuju panel" do
    sign_in_as_admin

    get root_url

    assert_select "a[href=?]", admin_registrations_path
  end
end
