# Kategori lomba untuk versi pertama. Aman dijalankan berulang kali.
[
  { name: "5K", quota: 50, price: 75_000 },
  { name: "10K", quota: 30, price: 125_000 }
].each do |attributes|
  Category.find_or_create_by!(name: attributes[:name]) do |category|
    category.quota = attributes[:quota]
    category.price = attributes[:price]
  end
end

puts "Kategori tersedia: #{Category.pluck(:name).join(', ')}"
