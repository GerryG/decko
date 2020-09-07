class Multideck < ActiveRecord::Migration[6.0]
  def change
    add_column :cards, :deck_id, :integer, default: 1

    remove_index :cards, column: ['key'], name: "cards_key_index"
    add_index :cards, ['key', 'deck_id'], name: "cards_key_index", unique: true
  end
end
