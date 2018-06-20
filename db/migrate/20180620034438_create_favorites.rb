class CreateFavorites < ActiveRecord::Migration[5.0]
  def change
    create_table :favorites do |t|
      t.references :user, foreign_key: true
      t.references :micropost, foreign_key: true

      t.timestamps
      # [:user_id, :micropost_id]がペアで保存されるのを防いでいる。そのための uniqueをtrueに。
      t.index [:user_id, :micropost_id], unique: true
    end
  end
end
