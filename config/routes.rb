Proman::Application.routes.draw do
  resource :user_session, :only=>[:new, :create, :destroy]
   
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
  namespace :notice do
    resources :notices, :only=>[:index, :show_message] do
      member do
        get :show_message
      end
    end
  end

  namespace :nego do
    resources :deals do
      collection do
        get :csv_export
      end
      resources :sales_reports
      member do
        delete :delete_related_file
        get :download_related_file
      end
    end
  end
  
  namespace :prj do
    match '/projects(/:id)/on_change_deal_list'
    match '/projects(/:id)/on_change_section_list'
    match '/projects(/:id)/on_click_prj_member_add'
    match '/projects(/:id)/on_click_prj_member_delete'
    match '/projects(/:id)/on_click_prj_member_total'
    match '/projects(/:id)/on_change_prj_member_planned_man_days'
    match '/projects(/:id)/on_click_work_type_total'
    match '/projects(/:id)/on_change_status_list'
    match '/projects(/:id)/on_click_related_project_add'
    match '/projects(/:id)/on_click_related_project_delete'
    match '/projects(/:id)/on_click_expense_budget_total'
    match '/projects(/:id)/on_click_sales_cost_add'
    match '/projects(/:id)/on_click_sales_cost_delete'
    match '/projects(/:id)/edit_prj_members'
    get '/projects/man_days_detail'
    resources :projects do
      collection do
        get :output_man_days
        put :send_man_days
      end
      member do
        put :update_prj_members
        put :lock
        put :unlock
        put :start
        put :finish
        put :restart
        put :restore
      end
    end
    resources :prj_reflections, :only=>[:show, :edit, :update, :project_report] do 
      member do
        get :project_report, :action => :report
        get :on_change_finished_date
      end
    end
  end
  
  namespace :expense do
    match '/expenses(/:id)/on_change_expense_type'
    resources :expenses
  end
  
  namespace :mh do
    match '/results(/:id)/on_change_project_list'
    match '/results(/:id)/get_results_by_day'
    match '/results/get_results_by_user_and_day'
    resources :results do
      collection do
        post :bundle_reflect
        get :bundle_reflect
        get :show_by_date
        get :sum_by_group
        get :sum_by_user
      end
    end
    resources :csv_results, :only=>[:index] do
      collection do
        post :csv_data_create
        put :actual_data_create
      end
    end
  end
  
  namespace :schedule do
    match '/schedules(/:id)/on_change_project_list'
    match '/schedules(/:id)/on_click_schedule_member_add'
    match '/schedules(/:id)/on_click_schedule_member_remove'
    match '/schedules(/:id)/get_schedules_by_day'
    resources :schedules do
      member do
        put :reflect
      end
      collection do
        post :bundle_reflect
        get :bundle_reflect
        get :show_by_date
        get :list_by_group
        get :list_by_project
      end
    end
    resources :csv_schedules, :only=>[:index] do
      collection do
        post :csv_data_create
        put :actual_data_create
      end
    end
  end
  
  namespace :historic do
    resources :historic_data, :only => [:index] do
      collection do
        get :detail
      end
    end
  end

  namespace :pwd do
    resource  :user, :only => [:edit, :update]
  end
  
  namespace :admin do
    match '/users(/:id)/on_click_unit_price_add'
    match '/users(/:id)/on_click_unit_price_delete'
    match '/indirect_costs(/:id)/on_click_indirect_cost_method'
    resources :users do
      member do
        put :restore
      end
    end
    resources :customers
    resources :occupations
    resources :development_languages
    resources :messages
    resources :operating_systems
    resources :databases
    resources :tax_divisions
    resources :expense_types
    resources :work_types
    resources :indirect_costs
    resource  :system_setting, :only => [:edit, :update]
    resources :sections do
      member do
        put :restore
      end
    end
  end
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  root :to => 'notice/notices#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id))(.:format)'
  
  match('/login' => 'user_sessions#new', :as => 'login')
  match('/logout' => 'user_sessions#destroy', :as => 'logout')
  match('/top' => 'notice/notices#index', :as => 'top')
end
