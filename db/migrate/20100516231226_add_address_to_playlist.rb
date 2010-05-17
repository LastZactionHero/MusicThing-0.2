class AddAddressToPlaylist < ActiveRecord::Migration
  def self.up
    add_column :playlists, :address, :string
  end

  def self.down
    remove_column :playlists, :address
  end
end
