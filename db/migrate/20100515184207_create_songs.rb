class CreateSongs < ActiveRecord::Migration
  def self.up
    create_table :songs do |t|
      t.string :title
      t.string :artist
      t.string :album
      t.string :filename
      t.string :art_filename
      t.string :submitter_name
      t.integer :playlist_idx

      t.timestamps
    end
  end

  def self.down
    drop_table :songs
  end
end
