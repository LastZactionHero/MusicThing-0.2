class AddAddressToSong < ActiveRecord::Migration
  def self.up
    add_column :songs, :address, :string
  end

  def self.down
    remove_column :songs, :address
  end
end
