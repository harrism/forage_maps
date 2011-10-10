class CreateTuckers < ActiveRecord::Migration
  def self.up
    create_table :tuckers do |t|
      t.string  :title
      t.text    :description
      t.decimal :lat, :precision => 15, :scale => 11, :default => 0
      t.decimal :lng, :precision => 15, :scale => 11, :default => 0
      t.integer :user_id

      t.timestamps
    end
    add_index :tuckers, [:user_id, :created_at]
  end

  def self.down
    drop_table :tuckers
  end
end
