class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :author, null: false, foreign_key: true
      t.string :title, null: false
      t.date :published_at, null: false
      t.timestamps
    end
  end
end
