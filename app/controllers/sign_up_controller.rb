class SignUpController < ApplicationController

  before_action :set_options, only: [ :new_user, :new_session, :update_user, :user_by_email, :user_by_username ]
  before_action :validate_token, only: [ :update_user, :user_index ]

  def new_user
    ldap_options = {
      :body => {
        :email => params[ :email ],
        :password => params[ :password ],
        :nick => "hola",
        :name => "hola"
      }.to_json,
        :headers => {
        'Content-Type' => 'application/json'
      }
    }
    ldap_results = HTTParty.post( @@ldap_url + '/user/resources/ldapcruds', ldap_options )
    results = HTTParty.post( @@sign_up_ms_url +  '/auth', @options )
    render :json => jsonify( results ), :status => results.code
  end

  def new_session
    ldap_options = {
      :body => {
        :email => params[ :email ],
        :password => params[ :password ],
        :nick => "hola",
        :name => "hola"
      }.to_json,
        :headers => {
        'Content-Type' => 'application/json'
      }
    }
    ldap_results = HTTParty.post( @@ldap_url +  '/user/resources/ldap', ldap_options )
    unless jsonify( ldap_results )[ 'login' ] == 'True'
      render :json => {
          :msg => "Unauthorized",
          :code => 401,
          :description => "Invalid credentials for LDAP"
        }, :status => 401
      return
    end

    sign_up_results = HTTParty.post( @@sign_up_ms_url +  '/auth/sign_in', @options )
    if sign_up_results.include? 'errors'
      render :json => jsonify( sign_up_results ), :status => sign_up_results.code
      return
    end

    sessions_results = HTTParty.post( @@sessions_ms_url + '/sign_in', @options )
    unless sessions_results.include? 'token'
      render :json => jsonify( sessions_results ), :status => sessions_results.code
      return
    end

    response.headers[ 'x-access-token' ] = jsonify( sessions_results )[ 'token' ]
    render :json => jsonify( sign_up_results ), :status => sign_up_results.code
  end

  # TODO
  def update_user
    results = HTTParty.put( @@sign_up_ms_url + "/users/#{@@user_data['id']}", @options )
    render :json => jsonify( results ), :status => results.code
  end

  def user_index
    results = HTTParty.get( @@sign_up_ms_url + "/users/#{@@user_data['id']}" )
    render :json => jsonify( results ), :status => results.code
  end

  def user_by_email
    results = HTTParty.post( @@sign_up_ms_url + "/email", @options )
    render :json => jsonify( results ), :status => results.code
  end

  def user_by_username
    results = HTTParty.post( @@sign_up_ms_url + "/username", @options )
    render :json => jsonify( results ), :status => results.code
  end

  private
    def set_options
      @options = parse_options( params )
    end

end
