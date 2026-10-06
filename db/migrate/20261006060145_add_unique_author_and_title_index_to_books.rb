class AddUniqueAuthorAndTitleIndexToBooks < ActiveRecord::Migration[8.1]
  def change
    add_index :books, [ :author_id, :title ], unique: true
  end
end
