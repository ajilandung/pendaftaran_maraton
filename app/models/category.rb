class Category < ApplicationRecord
  has_many :registrations, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :quota, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Sisa kuota dihitung dari seluruh pendaftaran, lunas maupun belum (R12).
  def remaining_quota
    quota - registrations.count
  end

  def full?
    remaining_quota <= 0
  end

  # Dipakai bilah kuota di halaman utama, dalam persen bulat 0-100.
  def filled_percentage
    return 100 if quota.to_i.zero?

    ((quota - remaining_quota).to_f / quota * 100).clamp(0, 100).round
  end
end
