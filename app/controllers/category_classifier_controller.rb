class CategoryClassifierController < ApplicationController

  before_action :validate_token, except: [ :all_categories ]
  before_action :validate_song, only: [ :create, :update, :delete, :category_for_file ]
  before_action :set_options, only: [ :create, :update, :create_user_categories, :update_user_categories, :delete_user_categories ]

  def index
    results = HTTParty.get( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/matches" )
    render :json => jsonify( results ), :status => results.code
  end

  def create
    results = HTTParty.post( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/match", @options )
    render :json => jsonify( results ), :status => results.code
  end

  def update
    results = HTTParty.put( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/match", @options )
    render :json => jsonify( results ), :status => results.code
  end

  def delete
    results = HTTParty.delete( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/match/#{params[:file_id]}" )
    render :json => jsonify( results ), :status => results.code
  end

  def all_categories
    results = HTTParty.get( @@category_classifier_ms_url + "/categories" )
    render :json => jsonify( results ), :status => results.code
  end

  def user_categories
    results = HTTParty.get( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/categories" )
    render :json => jsonify( results ), :status => results.code
  end

  def create_user_categories
    results = HTTParty.post( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/categories", @options )
    render :json => jsonify( results ), :status => results.code
  end

  def update_user_categories
    results = HTTParty.put( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/categories", @options )
    render :json => jsonify( results ), :status => results.code
  end

  def delete_user_categories
    results = HTTParty.delete( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/categories", @options )
    render :json => jsonify( results ), :status => results.code
  end

  def category_for_file
    results = HTTParty.get( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/category_for_file/#{params[:file_id]}" )
    render :json => jsonify( results ), :status => results.code
  end

  def files_for_category
    results = HTTParty.get( @@category_classifier_ms_url + "/user/#{@@user_data['id']}/files_for_category/#{params[:category_id]}" )
    if results.code == 200
      data = []
      jsonify( results )[ 'data' ].each do |song|
        song_data = HTTParty.get( @@information_ms_url + "/songs/#{song['file_id']}" )
        data.push( jsonify( song_data ) )
      end
      render :json => data, :status => results.code
    else
      render :json => jsonify( results ), :status => results.code
    end
  end

  private
    def set_options
      @options = parse_options( params )
    end

    def validate_song
      results = HTTParty.get( @@upload_ms_url + "/songs/#{params[:file_id]}" )
      unless results.code == 200 and jsonify( results )[ 'song' ][ 'user_id' ].to_s == @@user_data[ 'id' ].to_s
        render :json => default_error( 'Bad request', 400, 'The song does not exist or you are not authorized for that song.' ), :status => 400
        return
      end
    end

end
