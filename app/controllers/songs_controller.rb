class SongsController < ApplicationController
  
  protect_from_forgery :only => [:create, :update, :destroy] 
  
  # GET /songs
  # GET /songs.xml
  def index
    @songs = Song.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @songs }
    end
  end

  # GET /songs/1
  # GET /songs/1.xml
  def show
    @song = Song.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @song }
    end
  end

  # GET /songs/new
  # GET /songs/new.xml
  def new
    @song = Song.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @song }
    end
  end

  # GET /songs/1/edit
  def edit
    @song = Song.find(params[:id])
  end

  # POST /songs
  # POST /songs.xml
  def create
    @song = Song.new(params[:song])

    respond_to do |format|
      if @song.save
        flash[:notice] = 'Song was successfully created.'
        format.html { redirect_to(@song) }
        format.xml  { render :xml => @song, :status => :created, :location => @song }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @song.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /songs/1
  # PUT /songs/1.xml
  def update
    @song = Song.find(params[:id])

    respond_to do |format|
      if @song.update_attributes(params[:song])
        flash[:notice] = 'Song was successfully updated.'
        format.html { redirect_to(@song) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @song.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  # DELETE /songs/1.xml
  def destroy
    @song = Song.find(params[:id])
    @song.destroy

    respond_to do |format|
      format.html { redirect_to(songs_url) }
      format.xml  { head :ok }
    end
  end
  
  # Playlist Viewer /songs/viewer
  def viewer
    if params[:address]
      session[:playlist_address] = params[:address]
	end
  end
  
  # Song uploader /songs/uploader
  def uploader
  
  end
  
  # Process song upload /songs/uploader_process
  def uploader_process  
	# Get parameters
	submitter_name = params[:submitter_name]
	data_file = params[:data_file]
	
	# Upload
	Song.upload_file( submitter_name, data_file, session[:playlist_address] )
	
	# Redirect
	redirect_to :action => "uploader_complete"
  end
  
  # Song upload complete
  def uploader_complete
  
  end
  
  # Playlist generation
  def playlist_generate
	@current_track_idx = params[:id]
	@song_list = Song.all.select{ |song| song.address == session[:playlist_address] }
	@song_list = @song_list.sort_by{ |song| song.playlist_idx }
	
	
	puts "Current Track Idx: #{@current_track_idx}\n"
  end
  
  # Player generation
  def player_generate
    current_track_idx = params[:id]
	@player = params[:player].to_s
	puts "Player: #{@player}\n";
	
	@filename = ""
	
	@song_list = Song.all.select{ |song| song.address == session[:playlist_address] }
	@song_list.each do |song|
	  @filename = song.filename if song.playlist_idx == current_track_idx.to_i
	end
	
	puts "Filename: #{@filename}\n"
  end

end
