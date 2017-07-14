##1. Sending Requests And Responses
1. Defining A Route
  - Ruby Tips:
    (1) `get '/hello_world' => 'application#hello_world'` is basically just a method call. 
    It calls the get method passing in a hash as a parameter: 
      `get({'/hello_world' => 'application#hello_world'})`
    (2) `render({:plain => 'Hello, World!'})` == `render({plain: 'Hello, World!'})`

##2. Rendering HTML with Views
1. a controller's job is not to hold content, it orchestrates calling other methods in the application 
   and, when needed, put the results together - controller the director of the request handling
2. `render 'application/hello_world'` ==  `render inline: File.read('app/views/application/hello_world.html')`

##3. Making App Dynamic
1. Dynamic Server Responses