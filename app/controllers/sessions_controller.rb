class SessionsController < ApplicationController
  ADMIN_PASSWORD = Rails.application.credentials.admin_password ||
    raise("admin_password belum ada di credentials. Set lewat: ruby bin/rails credentials:edit")

  # Menebak kata sandi jadi mahal kalau percobaannya dibatasi. rate_limit adalah
  # bawaan Rails 8; hitungannya disimpan di Rails.cache dan dikelompokkan per alamat
  # IP. Di test cache sengaja dimatikan (:null_store), jadi pembatasan ini tidak
  # ikut mengganggu tes yang berkali-kali memanggil login.
  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to login_path, alert: "Terlalu banyak percobaan masuk. Coba lagi beberapa menit lagi." }

  def new
    redirect_to admin_registrations_path if admin_signed_in?
  end

  def create
    if correct_password?(params[:password])
      sign_in_admin
      redirect_to admin_registrations_path, notice: "Selamat datang, panitia."
    else
      flash.now[:alert] = "Kata sandi salah."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out_admin
    redirect_to root_path, notice: "Anda sudah keluar dari panel panitia."
  end

  private
    # secure_compare membandingkan seluruh karakter, bukan berhenti di karakter
    # pertama yang berbeda, sehingga lama pemeriksaan tidak membocorkan kata sandi.
    def correct_password?(submitted)
      ActiveSupport::SecurityUtils.secure_compare(submitted.to_s, ADMIN_PASSWORD)
    end
end
