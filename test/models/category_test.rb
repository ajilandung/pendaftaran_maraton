require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "sisa kuota adalah kuota dikurangi jumlah pendaftaran" do
    category = Category.create!(name: "Test 3K", quota: 5, price: 50_000)
    2.times { |i| create_registration(category, "peserta#{i}@example.com") }

    assert_equal 3, category.remaining_quota
  end

  test "sisa kuota menghitung pendaftaran yang belum lunas juga" do
    category = Category.create!(name: "Test 7K", quota: 2, price: 50_000)
    create_registration(category, "belum@example.com")

    assert_equal 1, category.remaining_quota
    assert_not category.full?
  end

  test "kategori penuh ketika sisa kuota habis" do
    assert categories(:fun_run).full?
    assert_equal 0, categories(:fun_run).remaining_quota
  end

  test "sisa kuota bertambah setelah satu pendaftaran dihapus" do
    category = categories(:fun_run)
    assert category.full?

    registrations(:andi).destroy!

    assert_equal 1, category.reload.remaining_quota
    assert_not category.full?
  end

  test "nama kategori harus unik" do
    duplicate = Category.new(name: categories(:five_k).name, quota: 10, price: 50_000)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "menjalankan seed dua kali tidak menghasilkan kategori ganda" do
    Rails.application.load_seed
    count_after_first_run = Category.count

    Rails.application.load_seed

    assert_equal count_after_first_run, Category.count
  end

  test "persentase terisi mencerminkan porsi kuota yang sudah dipakai" do
    category = Category.create!(name: "Test 4K", quota: 4, price: 50_000)
    create_registration(category, "seperempat@example.com")

    assert_equal 25, category.filled_percentage
  end

  test "kategori penuh berpersentase seratus" do
    assert_equal 100, categories(:fun_run).filled_percentage
  end

  test "kategori kosong berpersentase nol" do
    category = Category.create!(name: "Test 8K", quota: 10, price: 50_000)

    assert_equal 0, category.filled_percentage
  end

  private
    def create_registration(category, email)
      Registration.create!(
        name: "Peserta",
        email: email,
        phone: "081200000000",
        jersey_size: "M",
        category: category
      )
    end
end
