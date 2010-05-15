require 'net/ftp'
require 'mp3info'

class Song < ActiveRecord::Base

  # MP3 Tag Extract Data Storage
  class FileTags
    attr_accessor :title, :artist, :album
  	
    def initialize( title, artist, album )
	  @title = title
	  @artist = artist
	  @album = album
	  end
  end
	
  # Upload an MP3 File to the server and store
  # information to database
  def self.upload_file( submitter_name, data_file )
	  
	# Convert filename for storage on server
	upload_filename = generate_storage_filename( data_file.original_filename )
	  
	# Create Tempfile of upload
	tempfile = Tempfile.new( 'music_file_upload' )
	tempfile.puts data_file.read
	
	# Upload to ftp server
	upload_to_ftp( tempfile.path , upload_filename )
	
	# Exract Tag Data
	song_tags = extract_mp3_tags( tempfile.path ) 
	
	# Add database entry
	@song = Song.new()
	@song.title = song_tags.title
	@song.artist = song_tags.artist
	@song.album = song_tags.album
	@song.filename = "http://www.allweapons.net/musicthing/#{upload_filename}"
	@song.submitter_name = submitter_name
	@song.playlist_idx = get_next_playlist_idx()
	@song.save
	
	# Clean up
	tempfile.close
	
  end
	
	
  # Extract MP3 Tag Information
  def self.extract_mp3_tags( input_filename )
  	mp3 = Mp3Info.open( input_filename )
  	return FileTags.new( mp3.tag.title, mp3.tag.artist, mp3.tag.album )  
  end
  
  
  # Generate filename for storage on server
  def self.generate_storage_filename( input_filename )
  	# Replace spaces with '-'
	storage_filename = input_filename.gsub( / /, '-' )
	  
	# Prefix song name with database index number
	storage_filename = Song.all.size.to_s + storage_filename
	
	return storage_filename
  end
  
  
  # Get the index of the next playlist entry
  def self.get_next_playlist_idx()
    max = -1
	
	Song.all.each do |song|
	  max = song.playlist_idx if song.playlist_idx > max
	end
	
	return ( max + 1 )
  end
  
  # Upload file to FTP server
  def self.upload_to_ftp( input_filename, output_filename )
	
    # Connect to FTP
    ftp = Net::FTP.new
    puts ftp.connect( 'ftp.allweapons.net', 21 )
    ftp.login( 'zdicklin', 'foxForce5' )
    ftp.passive = true
	puts ftp.chdir( 'musicthing' )
	
	puts ftp.putbinaryfile( input_filename, output_filename )
	
    puts ftp.close
  end
  
end
