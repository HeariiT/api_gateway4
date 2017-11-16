Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  # Routes for sign_up_ms
  post '/sign_up',   to: 'sign_up#new_user'
  post '/sign_in',   to: 'sign_up#new_session'
  put  '/my',        to: 'sign_up#update_user'
  get  '/my',        to: 'sign_up#user_index'

  post '/email',     to: 'sign_up#user_by_email'
  post '/username',  to: 'sign_up#user_by_username'

  # Routes for sessions_ms
  post '/sign_out', to: 'sessions#sign_out'
  post '/refresh',  to: 'sessions#refresh_token'
  post '/validate', to: 'sessions#validate_user_token'

  # Routes for category_classifier_ms
  get    '/matches',        to: 'category_classifier#index'
  post   '/match',          to: 'category_classifier#create'
  put    '/match',          to: 'category_classifier#update'
  delete '/match/:file_id', to: 'category_classifier#delete'

  get    '/categories', to: 'category_classifier#all_categories'

  get    '/user_categories', to: 'category_classifier#user_categories'
  post   '/user_categories', to: 'category_classifier#create_user_categories'
  put    '/user_categories', to: 'category_classifier#update_user_categories'
  delete '/user_categories', to: 'category_classifier#delete_user_categories'

  get '/category_for_file/:file_id', to: 'category_classifier#category_for_file'
  get '/files_for_category/:category_id', to: 'category_classifier#files_for_category'

  #Routes that manage song's information and files

  resources :songs
  get 'download/:song_id',  to: 'songs#download'

end
