class GeocodingSupport < ActiveRecord::Migration
  def change
    rename_column :tuckers, :lat, :latitude
    rename_column :tuckers, :lng, :longitude
    change_column :tuckers, :latitude, :float, :default => 0.0
    change_column :tuckers, :longitude, :float, :default => 0.0
    add_column    :tuckers, :address, :string
  end
end
