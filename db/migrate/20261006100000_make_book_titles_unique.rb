class MakeBookTitlesUnique < ActiveRecord::Migration[8.1]
  def change
    remove_index :books, [ :author_id, :title ], unique: true
    add_index :books, :title, unique: true
  end
end
