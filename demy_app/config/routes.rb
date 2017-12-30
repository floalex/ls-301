Rails.application.routes.draw do
  get '/hello_world' => 'application#hello_world'
  get '/hello/:name'  => 'application#hello_world'
  
  get '/list_posts' => 'application#list_posts'
  get '/show_post/:id' => 'application#show_post'
  
  get '/new_post' => 'application#new_post'
  post '/create_post' => 'application#create_post'
  
  get '/edit_post/:id' => 'application#edit_post'
  post '/update_post/:id' => 'application#update_post'
  
  post '/delete_post/:id' => 'application#delete_post'
  
  post '/create_comment_for_post/:post_id' => 'application#create_comment'
  
  post '/show_post/:post_id/delete_comment/:comment_id' => 'application#delete_comment'
  
  get '/list_comments' => 'application#list_comments'
  
  
  ## RESTful
  
  ### posts ###

  # get    '/posts'          => 'posts#index'
  # get    '/posts/:id'      => 'posts#show'
  # get    '/posts/new'      => 'posts#new'
  # post   '/posts'   => 'posts#create'
  # get    '/posts/:id/edit' => 'posts#edit'

  # patch  '/posts/:id'      => 'posts#update'
  # put    '/posts/:id'      => 'posts#update'

  # delete '/posts/:id'      => 'posts#destroy'


  ### comments ###

  # get    '/comments'                    => 'comments#index'
  # post   '/posts/:post_id/comments'     => 'comments#create'
  # delete '/posts/:post_id/comments/:id' => 'comments#destroy'

end