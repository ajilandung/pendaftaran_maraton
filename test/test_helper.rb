ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Tes dijalankan berurutan. Suite sekecil ini selesai dalam dua detik, sementara
    # beberapa thread yang menulis ke satu berkas SQLite saling mengunci di Windows.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  # Dipakai tes yang perlu berada di balik login panitia. Sesinya dibuat lewat
  # form login yang sama seperti yang dipakai panitia sungguhan, bukan dengan
  # menyulap isi session, sehingga jalur masuknya ikut teruji.
  def sign_in_as_admin
    post login_url, params: { password: admin_password }
  end

  def admin_password
    Rails.application.credentials.admin_password
  end
end
