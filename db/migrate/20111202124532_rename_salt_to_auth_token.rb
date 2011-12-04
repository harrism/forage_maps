class RenameSaltToAuthToken < ActiveRecord::Migration
  def change
    rename_column :users, :salt, :auth_token
  end
end
