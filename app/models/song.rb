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
  def self.upload_file( submitter_name, data_file, playlist_address )
	  
	# Convert filename for storage on server
	upload_filename = generate_storage_filename( data_file.original_filename )
	  
	# Create Tempfile of upload
	tempfile = Tempfile.new( 'music_file_upload' )
	tempfile.puts data_file.read
	
	# Upload to ftp server
	upload_to_ftp( tempfile.path , upload_filename )
	
	# Exract Tag Data
	song_tags = extract_mp3_tags( tempfile.path ) 
	
	# Get Amazon.com album art jpeg url for song
	album_art_url = get_album_art_url( song_tags.artist + song_tags.album )
	puts album_art_url
	
	# Download album art jpeg
	jpeg_upload_filename = ""
	tempfile_jpeg = Tempfile.new( 'jpeg_file' )
	
	if( fetch_album_jpeg( album_art_url, tempfile_jpeg ) == :success )
	  # Upload album art to ftp server
	  jpeg_upload_filename = "album_art/" + upload_filename + ".jpg"
	  upload_to_ftp( tempfile_jpeg.path, jpeg_upload_filename )
	  jpeg_upload_filename = "http://www.allweapons.net/musicthing/" + jpeg_upload_filename
	  tempfile_jpeg.close
	end
	
	# Add database entry
	@song = Song.new()
	@song.title = song_tags.title.empty? ? "Unknown" : song_tags.title
	@song.artist = song_tags.artist.empty? ? "Unknown Artist" : song_tags.artist
	@song.album = song_tags.album.empty? ? "Unknown Album" : song_tags.album
	@song.filename = "http://www.allweapons.net/musicthing/#{upload_filename}"
	@song.submitter_name = submitter_name.empty? ? "Anonymous" : submitter_name
	@song.playlist_idx = get_next_playlist_idx( playlist_address )
	@song.art_filename = jpeg_upload_filename
	@song.address = playlist_address
	@song.save
	
	# Clean up
	tempfile.close
	
  end
	
	
  # Extract MP3 Tag Information
  def self.extract_mp3_tags( input_filename )
  	mp3 = Mp3Info.open( input_filename )
	
	mp3.tag.album = "" if ( mp3.tag.album == "Unknown" || mp3.tag.album == "unknown" )
	mp3.tag.artist = "" if ( mp3.tag.artist == "Unknown" || mp3.tag.artist == "unknown" )
	mp3.tag.title = "" if ( mp3.tag.title == "Unknown" || mp3.tag.title == "unknown" )
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
  def self.get_next_playlist_idx( playlist_address )
    max = -1
	
	Song.all.each do |song|
	  max = song.playlist_idx if ( song.playlist_idx > max ) && ( song.address == playlist_address )
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
  
  
  # Fetch jpeg at url
  def self.fetch_album_jpeg( url, tempfile )
    if( url.empty? )
      return :fail
    end

    uri = URI.parse( url )
    response = Net::HTTP.get_response( uri );

    case response
      when Net::HTTPSuccess
		tempfile.puts response.body
		puts "Response body size: #{response.body.size}\n"
		puts "tempfile size: #{tempfile.size}\n"
        return :success
      else
        return :fail
    end
  
    return :fail
  end


  # Get Amazon.com album art url for search term
  def self.get_album_art_url( search_terms )
    puts "get_album_art_url()\n"
	
    # Bail out if no search terms were entered
    if search_terms.empty?
      return ""
    end
  
    # Construct the search uri
    search_url = "http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Dpopular&field-keywords=" + search_terms.gsub( / /, '+' )
    uri = URI.parse( search_url )

    puts "search_url: #{search_url}\n"
	
    # Perform request
    response = Net::HTTP.get_response( uri )

    # Determine if response is valid
    response_body = ""
    case response
      when Net::HTTPSuccess
        response_body = response.body
      else
        return ""
    end

    # Bail out on empty response
    if response_body.empty? 
      return ""
    end

    # Search for album art url
    response_body.split( /\n/ ).each do |line|
      if( ( line.include? ".jpg" ) && ( line.include? "alt=\"Product Details\"" ) )

        r1 = Regexp.new( 'img.*.jpg' )
        img_src = line.scan( r1 )

        if( img_src )
          img_src_arr = img_src[0].split( /"/ )       
          if( img_src_arr.size == 2 )
		    return img_src_arr[1]
          end
        end
      end
    end

    return ""
  end

end
