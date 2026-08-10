require "test_helper"

class RegistrationTest < ActiveSupport::TestCase
  test "pendaftaran valid pada kategori yang masih punya sisa kuota tersimpan" do
    registration = build_registration

    assert registration.save
    assert_not registration.paid, "pendaftaran baru harus berstatus belum lunas"
  end

  test "pendaftaran tanpa nama ditolak" do
    registration = build_registration(name: "")

    assert_not registration.valid?
    assert_includes registration.errors[:name], "can't be blank"
  end

  test "pendaftaran dengan format email salah ditolak" do
    registration = build_registration(email: "budi.example.com")

    assert_not registration.valid?
    assert_includes registration.errors[:email], "is invalid"
  end

  test "email yang sudah terdaftar tidak bisa dipakai lagi" do
    registration = build_registration(email: registrations(:budi).email)

    assert_not registration.valid?
    assert_includes registration.errors[:email], "has already been taken"
  end

  test "email dinormalkan sehingga beda huruf besar tetap dianggap sama" do
    registration = build_registration(email: " BUDI@EXAMPLE.COM ")

    assert_not registration.valid?
    assert_includes registration.errors[:email], "has already been taken"
  end

  test "ukuran jersey di luar daftar yang tersedia ditolak" do
    registration = build_registration(jersey_size: "XXXL")

    assert_not registration.valid?
    assert_includes registration.errors[:jersey_size], "is not included in the list"
  end

  test "pendaftaran ke kategori yang sudah penuh ditolak" do
    registration = build_registration(category: categories(:fun_run))

    assert_not registration.valid?
    assert_includes registration.errors[:category], "sudah penuh"
  end

  test "kategori penuh tetap menolak meski pendaftaran yang mengisinya belum lunas" do
    assert_not registrations(:andi).paid, "prasyarat: slot diisi pendaftaran yang belum lunas"

    assert_not build_registration(category: categories(:fun_run)).valid?
  end

  test "pendaftaran lama di kategori penuh tetap bisa ditandai lunas" do
    registration = registrations(:andi)
    assert registration.category.full?

    assert registration.update(paid: true), registration.errors.full_messages.to_sentence
    assert registration.reload.paid
  end

  test "pendaftaran dihapus membebaskan slot kategorinya" do
    category = categories(:fun_run)
    registrations(:andi).destroy!

    assert build_registration(category: category).valid?
  end

  private
    def build_registration(attributes = {})
      Registration.new({
        name: "Rina Kusuma",
        email: "rina@example.com",
        phone: "081233334444",
        jersey_size: "L",
        category: categories(:five_k)
      }.merge(attributes))
    end
end
