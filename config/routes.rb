GoblinRails::Application.routes.draw do
  root :to => "application#index"
  
#  get "science/index"
  post "application/login"
  post "application/logout"
  
  get "science/main"
  get "science/my_projects"
  
  get "science/project_info"
  get "science/project_edit"
  get "science/members_edit"
  post "science/project_write"
  post "science/members_action"
  post "science/members_add"
  get "science/research_info"
  get "science/project_new"
  get "science/research_new"
  get "science/research_edit"
  get "science/research_members_edit"
  post "science/research_write"
  
  post "science/research_members_add"
  post "science/research_members_action"
  post "science/research_submit"
  post "science/research_finance"
  get "science/research_add_entry"
  post "science/research_entry_write"
  
  get "science/asset_return"
  post "science/asset_return_write"
  
  get "master/main"
  get "master/review"
  get "master/review_research"
  post "master/review_research_write"
  get "master/comment_research"
  post "master/comment_research_write"
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
