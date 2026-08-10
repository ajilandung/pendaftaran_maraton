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
end
