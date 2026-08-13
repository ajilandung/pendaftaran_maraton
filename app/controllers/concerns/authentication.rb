# Seluruh urusan "siapa yang sedang masuk" dikumpulkan di satu berkas, mengikuti
# bentuk concern Authentication bawaan generator Rails 8. Bedanya, aplikasi ini
# tidak punya model User: yang dijaga hanya satu kata sandi panitia, per R8.
#
# Aplikasi ini juga tidak menuntut login secara global seperti generator bawaan,
# karena hampir seluruh halamannya memang untuk umum. Hanya controller di
# namespace admin yang memanggil require_admin lewat before_action.
module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :admin_signed_in?
  end

  private
    # Satu-satunya tanda bahwa panitia sudah masuk adalah penanda di dalam session.
    # Rails menyimpannya di cookie yang ditandatangani, jadi pengunjung tidak bisa
    # memalsukannya sendiri dari peramban.
    def admin_signed_in?
      session[:admin].present?
    end

    def require_admin
      redirect_to login_path, alert: "Masuk dulu sebagai panitia." unless admin_signed_in?
    end

    # reset_session membuang id sesi lama lebih dulu, baru menandai panitia sudah
    # masuk. Tanpa itu, id sesi yang sempat dipegang orang lain sebelum login ikut
    # naik pangkat menjadi sesi panitia — celah yang dikenal sebagai session fixation.
    def sign_in_admin
      reset_session
      session[:admin] = true
    end

    def sign_out_admin
      reset_session
    end
end
