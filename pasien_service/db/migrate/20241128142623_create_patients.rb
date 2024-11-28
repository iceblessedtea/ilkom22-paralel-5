class CreatePatients < ActiveRecord::Migration[7.2]
  def change
    create_table :patients do |t|
      t.string :name      # Kolom untuk menyimpan nama
      t.string :email     # Kolom untuk menyimpan email
      t.timestamps        # Menambahkan kolom created_at dan updated_at
    end
  end
end