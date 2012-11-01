ActionController::Routing::Routes.draw do |map|

  # Resources
  map.resources :spots, :member => { :toggle_share => :put, :toggle_want => :put, :toggle_own => :put }
  map.resources :things, :member => { :toggle_featured => :put, :merge => :get }, :collection => { :search_autosuggest => :get }
  map.resources :collections
  map.resources :collection_things
  map.resources :comments
  map.resources :friends
  map.resources :followers
  map.followings '/followings', :controller => 'followings', :action => 'index'
  map.resources :recommendations
  map.resources :users, :has_many => [:spots, :collections], :member => { :import_friends => :get }, :collection => { :link_user_accounts => :get }
  map.resources :brands
  map.resources :stores
  map.resources :pages
  map.resources :invitations

  # Named routes for Users/Sessions
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
  #map.signup '/signup', :controller => 'users', :action => 'new'
  #map.settings '/settings', :controller => 'users', :action => 'edit', :user => current_user

  # Highscore
  map.highscore_things '/highscore/things', :controller => 'highscore', :action => 'things'
  map.highscore_users '/highscore/users', :controller => 'highscore', :action => 'users'
  map.highscore_brands '/highscore/brands', :controller => 'highscore', :action => 'brands'
  map.highscore_stores '/highscore/stores', :controller => 'highscore', :action => 'stores'
  map.highscore_competition '/highscore/competition', :controller => 'highscore', :action => 'competition'

  # Intro
  map.intro1 'intro', :controller => 'intro', :action => 'step1'
  #map.intro_step 'intro/:action', :controller => 'intro' # TODO: make this work
  map.intro2 'intro/step2', :controller => 'intro', :action => 'step2'
  map.intro3 'intro/step3', :controller => 'intro', :action => 'step3'
  map.intro4 'intro/step4', :controller => 'intro', :action => 'step4'
  map.intro_invitation 'intro/:invitation_token', :controller => 'intro', :action => 'step1'

  # Search
  map.search '/search/:search', :controller => 'spots', :action => 'index'

  # Statistics
  map.statistics 'statistics', :controller => 'statistics', :action => 'index'

  # User feed views
  map.connect 'users/:id/:view', :controller => 'users', :action => 'show', :id => 'id', :view => 'view'

  # Legacy URLs: products & spottings
  map.connect 'products', :controller => 'things', :action => 'index'
  map.connect 'products/:id', :controller => 'things', :action => 'show', :id => 'id'
  map.connect 'spottings', :controller => 'spots', :action => 'index'
  map.connect 'spottings/:id', :controller => 'spots', :action => 'show', :id => 'id'

  # Testing
  #map.test_web '/start/test_web', :controller => 'start', :action => 'test_web'

  # Root (start page)
  map.root :controller => 'spots', :action => 'index'

  # Default route -> Show Page
  map.connect ':id', :controller => 'pages', :action => 'show', :id => 'id'
  
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'

end