class WelcomeController < ApplicationController

  before_action( only: [ :new_category ] ) { user_id_exists?( params[ :user_id ] ) }

  def index
    msg = {
      :message => "Hello there!",
      :code => 200,
      :description => "I am the api gateway, and it seems i'm working :)."
    }
    render :json => msg, :status => :ok
  end

  def new_category
    msg = {
      :message => "Post test for user with id #{params[:user_id]}"
    }
    render :json => msg, :status => :ok
  end

end
