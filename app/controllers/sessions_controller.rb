class SessionsController < ApplicationController

  before_action :validate_token, only: [ :sign_out ]
  before_action :set_options, only: [ :sign_out, :refresh_token ]

  def sign_out
    results = HTTParty.post( @@sessions_ms_url + '/sign_out', @options )
    render :json => jsonify( results ), :status => results.code
  end

  def refresh_token
    results = HTTParty.post( @@sessions_ms_url + '/refresh', @options )
    render :json => jsonify( results ), :status => results.code
  end

  def validate_user_token
    if request.headers[ 'x-access-token' ].nil?
      msg = {
        :message => 'No access-token found'
      }
      render :json => msg, :status => :bad_request
      return
    end

    options = parse_options_with_session( {} )
    sessions_results = HTTParty.post( @@sessions_ms_url + '/validate', options )
    unless sessions_results.include? 'email'
      render :json => jsonify( sessions_results ), :status => sessions_results.code
      return
    end
    render :json => jsonify( sessions_results), :status => sessions_results.code
  end

  private
    def set_options
      @options = parse_options_with_session(params)
    end

end
