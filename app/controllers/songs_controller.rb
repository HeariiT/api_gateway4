class SongsController < ApplicationController

  before_action :validate_token

  #GET  /songs
  def index
    if getSongsByUser( @@user_data[ "id" ] )
      render json: @songs
    end
    #else
      #if getAllSongs()
      #  render json: @songs
      #end
    #end
    renderErrors();
  end

  #POST  /songs
  def create
      if uploadSong(params["attachment"])
        if postNewSong(params, @res)
          render json: @res
          return
        end
      end
    renderErrors();
  end

  #GET  /songs/:id
  def show
    if getSongByID(params["id"])
      render json: @songs
    end
    renderErrors();
  end

  #POST /download
  def download
    if downloadManager( params[:song_id] )
      downloadSong( )
    end
    renderErrors( )
  end

  #PUT  /songs/:id
  def update
    if updateSong(params)
      render json: @res
    end
    renderErrors();
  end

  #DELETE  /songs/:id
  def destroy
    if deleteDataSong(params["id"])
      if deleteSong(params["id"])
        render json: @res
      end
    end
    renderErrors();
  end

  #____________________________________________________________________________
  #------------------Middle Funcions-------------------------------------------

  def renderErrors()
    unless @error == nil
      render json:
      {
        code: @error["status"],
        message: @error["error"],
        description: @error["exception"],
      }
    end
  end

  def getAllSongs()
    response = HTTParty.get(@@information_ms_url + "/songs")
    if response.code == 200
      @songs = JSON.parse(response.body)
      return true
    else
      @error = response
      return false
    end
  end

  def getSongByID(id)
    response = HTTParty.get(@@information_ms_url + "/songs/" + id.to_s)
    if response.code == 200
      @songs = JSON.parse(response.body)
      return true
    else
      @error = response
      return false
    end
  end

  def getSongsByUser(user)
    response = HTTParty.get(@@information_ms_url + "/songs?user=#{user}")
    if response.code == 200
      @songs = jsonify( response )
      return true
    else
      @error = response
      return false
    end
  end

  def downloadManager( id )
    response = HTTParty.get(@@upload_ms_url + "/songs/" + id)
    if response.code == 200
      body = response.parsed_response
      @song_url = body["song"]["attachment"]["url"]
      return true
    else
      @error = response
      return false
    end
  end

  def downloadSong( )
    sanitized_url = @song_url
    raw_url = URI.parse( sanitized_url )
    filename = raw_url.path.split( '/' ).last
    path = Rails.root + 'tmp/' + filename

    song = File.open( path, 'wb' ) do |f|
      response = RestClient.post @@download_ms_url + '/download', {:url => sanitized_url}
      if response.code == 200
        f.write response.body
        send_file path, filename: filename, type: "audio/mp3", disposition: "attachment"
        return true
      else
        @error = response
        return false
      end
    end
  end

  def uploadSong(song)
    response = RestClient.post @@upload_ms_url + "/songs", {:user_id => @@user_data['id'], :attachment => song}
    response = jsonify( response )
    if response["code"] == 201
      @res = response
      return true
    else
      @error = response
      return false
    end
  end

  def postNewSong(params, res)
    response = RestClient.post @@information_ms_url + "/songs",
    {
      :user => @@user_data['id'],
      :id => res["song_id"],
      :title => params["title"],
      :author => params["author"],
      :album => params["album"],
    }
    if response.code == 200
      @res = JSON.parse(response.body)
      return true
    else
      @error = response
      return false
    end
  end

  def updateSong(params)
    options = {
      :body => {
        :id => params[:id],
        :user => @@user_data['id'],
        :title => params[:title],
        :author => params[:author],
        :album => params[:album]
      }.to_json,
      :headers => {
        'Content-Type' => 'application/json'
      }
    }
    response = HTTParty.put(@@information_ms_url + "/songs/" + params[:id], options)
    if response.code == 200
      @res = JSON.parse(response.body)
      return true
    else
      @error = JSON.parse(response.body)
      return false
    end
  end

  def deleteSong(id)
    # Deleting matches for this
    response = HTTParty.delete( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/match/#{id}" )
    response = RestClient.delete @@upload_ms_url + "/songs/" + id.to_s
    if response.code == 200
      @res = JSON.parse(response.body)
      return true
    else
      @error = JSON.parse(response.body)
      return false
    end
  end

  def deleteDataSong(id)
    response = HTTParty.delete(@@information_ms_url + "/songs/" + id.to_s)
    if response.code == 200
      @res = JSON.parse(response.body)
      return true
    else
      @error = response
      return false
    end
  end

end
