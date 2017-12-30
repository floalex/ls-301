**Without Rails Maric**

### 1. Sending Requests And Responses
1. Defining A Route
  - Ruby Tips:
    (1) `get '/hello_world' => 'application#hello_world'` is basically just a method call. 
    It calls the get method passing in a hash as a parameter: 
      `get({'/hello_world' => 'application#hello_world'})`
    (2) `render({:plain => 'Hello, World!'})` == `render({plain: 'Hello, World!'})`


### 2. Rendering HTML with Views
1. a controller's job is not to hold content, it orchestrates calling other methods in the application 
   and, when needed, put the results together - controller the director of the request handling
2. `render 'application/hello_world'` ==  `render inline: File.read('app/views/application/hello_world.html')`

### 3. Making App Dynamic
1. Dynamic Server Responses
  - The dynamic nature of web apps:
    1. The client embeds a piece of data inside the URL for the server to respond to. 
      e.g.  "https://www.google.com/search?q=robots": ask Google to contain only search results for "robots"
    2. server responds with data based on some internal state of the data in the server's database
      e.g. when visit Facebook, its server will retrive posts from your friends 

2. Dynamic Documents
* ERB - a templating engine that allows to embed Ruby code to have dynamic documents.

3. Responses With URL Capture Pattern
* `/hello/:name` to route any request with URL like `/hello/John` to the `hello_world` action in the ApplicationController


### 4. Persisting Data
1. Database backed
  - server queries the backend database and uses that query's result to assemble a response to return to the client.

2. Prepare the database
  1. Create table "posts" in `db/posts.sql` with the post's attributes, then populate with csv file
  2. Rails app that contains directories like app and db: `sqlite3 db/development.sqlite3 < db/posts.sql`
  3. Import csv file in SQL console `sqlite3 db/development.sqlite3`:
    * `.mode csv`
    * `.import db/posts.csv posts`

- command `.quit` to exit the sqlite REPL

3. Interacting With The Database
- Ruby library
  ```
  $ irb

  > require 'sqlite3'
  => true
  
  # setup db connection
  > connection = SQLite3::Database.new 'db/development.sqlite3'
  => #<SQLite3::Database:0x000000039ff288 ... >
  ```
- can ask connection to return rows in hash format:
  ```
  $irb
  
  > connection.results_as_hash = true
  ```
  

## 5. List and Show Records
1. Posts index page:
  Three things:
  1. a route
  2. an action
  3. a view

2. Show A Post To The User
  - same actions as index above for the 3 steps
  - include safe code in show_post action
    * `connection.execute("SELECT * FROM posts WHERE posts.id = ? LIMIT 1", params['id'])`
      * The ? character in above statement is a placeholder that will be replaced by the value 
        of the second parameter, which is params['id']. This is a safer way to include user's 
        input (in this case, from the URL) in a SQL statement to against SQL Injection Attacks
    * Unsafe statement by including user's input directly in SQL code
      `connection.execute("SELECT * FROM posts WHERE posts.id = #{params['id']} LIMIT 1")`

3. Extract Shared Logic
  - good practice as if we need to change things about our database connection later, 
    we can just make the change in a single place. Also other actions need this database
    connection then they can make use of this same method as well.


## 6. Create a New Record Using a Form
defining a route, action, and view to serve the new post form to the client:
1. Displaying a form 
  1. provide user with a form to collect the details of a post
  2. receive that submitted form data and add it as a new post to our collection of posts
  3. what determines the keys for the POST data?
    * The name attribute on an <input>. Rails will place these POST data pairs into params

2. Creating a Post
  Define the route and the action the previous form submits to.
  - How to implement the post action with pure SQL?
    1. execute some SQL to INSERT the new post into the posts table. Since the SQL query string 
       is multiline, we define it using a heredoc (the `<<-SQL ... SQL` syntax), and inside 
       we see four ?s for the values of our four post attributes.
    2. those four values passed in as arguments to `connection.execute`, following the 4 query argument.
       These values are in `params['name']` based on the name attributes of the <input>s in our new_post <form>.   
    3. SQLite3 handles our ids automatically, don't need to worry about setting those.
    4. with our new post successfully added to the database, we respond to the client by 
       redirecting them back to the list of posts. Redirecting is accomplished with Rails `redirect_to` method.
    5. Create the link page for new post and back to the posts

  * To see what goes on for a redirect, let's look again at our response object, but this time, after our redirect_to call:
  ```
  # assuming we're inside the create_post action above...

  redirect_to '/list_posts'
  require 'pry'; binding.pry;
  
  response.body
  # => "<html><body>You are being <a href=\"http://localhost:3000/list_posts\">redirected</a>.</body></html>"
  
  response.content_type # => nil
  
  response.status #  => 302
  
  response.headers
  # => {
  #      # ...
  #      "Location"=>"http://localhost:3000/list_posts"
  #    }
  
  response.headers['Location']
  # => "http://localhost:3000/list_posts"
  ```
  
  * `id` attritubes in form has two important benefits:
  1. When the user click the label, the focus will go to the input field
  2. It benefits for visually impaired users who use screen readers as the screen
     readers depend on the id attributes to associate form inputs with labels

## 7. Edit a Record
1. Editing and Updating a Post
  1. provide the user with a form to allow editing of the existing post(get it with the id)
    *This `edit_post` view is identical to the new_post with three exceptions:
      (1). our submit button reads Update Post
      (2). all of the <form> fields are populated with the values of the post
      (3). the <form> action attribute points to our new route (using the proper post ID)
  2. receive that submitted form data and update the appropriate post in the database

- The key differences are that the edit_post route requires a post ID (since editing, unlike 
  creating a post, is in reference to an existing database row) and the edit_post view needs 
  to populate its <form> with the values of the post it represents.

## 8. Find and Delete a Record
1. Extract Finding A Post to make it more reusable
  - refactoring our logic into one place like this makes it:
    (1) easy to change later, because now we'll only need to make a change in one place
    (2) reuse the same logic by other methods

2. Delete a Post
 1. The `<form>` action has the format `/delete_post/:id` so we route those requests to `application#delete_post`.
 2. Inside `application#delete_post`, we see the familiar pattern we noticed in `create_post` and `update_post`
   (1) make change to the database
   (2) redirect

## 9. Controller Patterns and CRUD
1. Controller Patterns in a Datacentric App
  our controller doing the following two things:
  (1) Interacting with the database, either read data from the database (with a SELECT SQL statement)
      or rite data to the database (with INSERT, UPDATE or DELETE SQL statements)
  (2) Use the retrieved data to render a view template (in case a "read"), 
      or redirect to a different page (in case of a "write")
  The controller stands between the data (in the database) and the presentation (the view templates) to coordinate the flow.

2. CRUD represents four basic actions to interact with data. 
  The four resource actions here map directly to SQL's four core commands: INSERT, SELECT, UPDATE and DELETE

## 10. Data Encapsulation With Models
1. Creating a New Post
  - encapsulation: move all SQL commands about a piece of data into a single place(class), so they can be easily updated
  - Define the `Post` class with the attributes then move the codes to the class 
    * wrap the database access steps in a `save` method
    * The logic in the controller action is much simpler - just going to instantiate a post object from the params, 
      which has all of the user's inputs, and tell the post object to save itself into the database.

2. Find, Show, Edit, Delete a Post
  Since we changed the type of objects that are passed into the view as posts. Before they were Hash objects, 
  and now they're Post objects, and accessing its attributes is now easier.

## 11. Expanded Encapsulation Through Our Models
1. Update a Record
  - The way to tell if a record is a new record or not is to check its id column 
    - if it's `nil` it's a new record
    - adjust model code to either INSERT or UPDATE records based on whether the post is a new or existing one
    - need to implement the `set_attributes`

2. Delete a Post Model
  - Implement `destroy` method in the class

3. List Posts
  (1) define a class method in the Post class that executes the SQL command to return all the posts in a hash
  (2) then we'll use map to create an array of Post objects
  (3) use our Post model methods in the view

## 12. Model Validations
1. Model Validation
  - whenever an application allows user's input, we want to validate the data as early as possible
  - Rails provides `present?` method for validation
  - Use guard clause before saving the data

2. Integrate Validations With Forms
  when the user provides invalid inputs, we want to:
  (1) "bounce back" to the page with the input form instead of taking to new page
  (2) preserve the user's input so they don't have to fill the form from scratch
  (3) show the user what input field(s) are not valid
  * When you reload a page with a browser, it asks the browser to replay the ast HTTP request. 
  * In the case of a form submission with errors, the last request will be a POST request because 
    the behavior on the server side is to render the form and not redirect to another path.

3. Display Validations
  - Add `errors` attribute in the post object
  - Iterate through the errors hash in the view if any exists

## 13. A Second Resource
1. Adding Comments to Our App
  (1) create a new table (define a structure): some SQL to create the table
  (2) populate that table with rows (place data in that structure)

2. Displaying Comments
  (1) get collection of comments associated with the post from the DB inside the controller action and pass them to the view
  (2) display the comments in the view

3. Comment model
- The file app/models/comment.rb contains an `initialize` and `new_record?` method similar to those found in Post.

## 14. Working With Model Associations
1. Association Between Models
  - not the ideal solution by executing SQL statement in the controller as the SQL command needs 
    a post id to find the comments: Better to move it to the Post model

2. Creation Through Association
  - creating a comment will very much resemble creating a post
  - The primary difference in creating a comment is our concern for post_id. 
  - When creating a comment, we'll need to be sure to associate it with the right post.
  - 3 steps:
    (1) point the <form> action to a path that includes post.id:
        `<form method="post" action="/create_comment_for_post/<%= post.id %>">`
    (2) capture this post_id in the route:
        `post '/create_comment_for_post/:post_id' => 'application#create_comment'`
    (3) make sure to set the post_id for the row in the comments table:
        ```
        connection.execute insert_comment_query,
          params['body'],
          params['author'],
          params['post_id'],
          Date.current.to_s
        ```
  - At the end of `create_comment`, we just redirect back to show_post

## 15. Cleaning up
1. Validation for Creating a Comment
  (1) The body and author field both have to be present.
  (2) If validation fails, we want the user to stay on the previous create comment page with the 
      fields of the comment form populated.
      - Note that the create comment page is actually our show_post page, we want to show the 
        comment errors message on that page. We need to call `comment.errors` there. Therefore
        in `show_post` method in controller, we need to instantiate an empty comment object there.

2. Delete a Comment
  1. set up the route 
  2. add in a form that allows us delete a comment from a Post in the show_post view
  3. controller action for deleting a comment, remember to redirect the user to the same page
  4. Comment model and find the comment id then delete

3. List Comments
  1. start with the view template: "list_comments.html.erb "
  2. set up `list_comments` route
  3. controller action for the `list_comments` to get all the comments
    * Note, that in our view, list_comments.html.erb we are using the method `comment.post`.
      Define the method in the Comment model.

## 16. A Base Model
- Inheriting From a Base Model
  - pull the common methods in the models like `new_record?` and place them inside a `BaseModel`
  - let Post and Comment inherit from BaseModel
  - We can omit the classes and call new all by itself
    * if we call new inside of this class method, it will be called on the class it lives in
    * give our classes a .table_name method to figure out the appropriate table name string
    * inside of a class method self is the class
  - This process of having an object look at itself is called **introspection**. 


** With Rails Convention **

## 1. Routes and Resources
  - data-centric apps (or CRUDy apps) tend to have very similar ways for letting users interact with the application
  - REST stands for "Representational State Transfer"
    * a software architecture style and guideline to create scalable web services
    * RESTful interfaces center around "nouns" or "resources
    * remove "verbs" from the interfaces but instead relying on the standardized HTTP verbs (GET/POST/PUT/DELETE)
  - RESTful interfaces standardized web application interaction patterns to make them easier to understand
    - streamline your application to align with how the backend data is stored in databases
    - makes development easier
  
  * root: specify what action maps to "/"(the top-level URL of our site which has no path)
  * match + via: match is used to match URL patterns to one or more routes. 
  * as: make our URL helpers better match custom URLs
  * collection route: Match a URL with path `/posts/popular`
  * passing an extra parameter: via the params hash
  
  -  A route interprets an incoming HTTP request and:
    1. matches a request to a controller action based on HTTP verb and the request URL pattern
    2. captures data in the URL in `params` for controller actions
    3. can use the resources macro to generate RESTful routes very quickly

## 2. Conventional Views and Controller Actions
1. Restful Controller Conventions
  - RESTful conventions based on resources don't stop with routes
  - organize all the actions related to the resources in the controller
    * typical Rails controller will have a subset of RESTful actions of 
      index, show, new, edit, create, update, and destroy
  - if you find yourself adding actions such as create_draft, delete_draft, update_draft etc. to 
    the PostsController, it's a sign that you should think about having a DraftsController with
    create, delete and update actions

2. Rendering Views With Instance Variables
- Instance variables are automatically available in view templates

## 3. Controller Action and View File Structure
  - Rails will automatically look for a view template in directory matches the controller resource's name,
    with the name that matches the controller action's name
  - Either explicitly tell Rails what view template to render, or set the response header with a redirect.
  - RESTful conventions:
    * list_posts -> list -> index
    * show_post -> show
    * new_post -> new
    * create_post -> create
    * edit_post -> edit
    * update_post -> update
    * delete_post -> delete -> destroy

## 4. Filters and Indifferent Access
  - private method in controller action will never be routed to


## 5. Indifferent Access

## 6. More Controller Options
1. Status Codes and Request Formats
  - Set explicit response header status code
    ```
    def four_oh_four
      # specific HTTP status code for the response
      render plain: '404 Not Found', status: :not_found
      # Fixnums also work:
      # render plain: '404 Not Found', status: 404
    end
    ```
  - Respond to multiple request formats
  ```
  def greeting
    # respond differently to different formats...
    respond_to do |format|
      # render one response for HTML requests
      format.html { render inline: "<p>Hi!</p>" }
      # render another for JSON requests
      format.json { render json: {greeting: 'Hi!'} }
    end
  end
  ```
  - Given a /greeting route to this action:
  ```
  $ curl localhost:3000/greeting    
  <p>Hi!</p>
  $ curl localhost:3000/greeting.html
  <p>Hi!</p>
  $ curl localhost:3000/greeting.json
  {"greeting":"Hi!"}
  ```


## 7. The link_to Helper
  - link_to is a Rails built in helper that helps generate an anchor tag.
    It works like this: `<%= link_to 'Link Text', url_or_path %>`
  - Helpers, or more specifically, view helpers are methods that generate HTML snippets in a view.
    ```
    <%= link_to 'Back to Posts', posts_path %>

    <!-- this generates the HTML... -->
    
    <a href="/posts">Back to Posts</a>
    ```
  
  - We can actually create similar method ourselves:
  ```
  ### app/helpers/application_helper.rb ###: 
  ### methods defined here will automatically become helpers and can be used in views ###

  module ApplicationHelper
    def my_link_to(text, href)
      "<a href='#{href}'>#{text}</a>".html_safe
    end
  end
  ```

## 8. Nonstandard HTTP Verbs
  - browsers natively only support HTTP GET and POST methods
  - On the server side, Rails is able to examine the "_method" value in the params to restore 
    the semantics of the HTTP request.
  - to use HTTP POST to fake PUT/PATCH/DELETE methods:
  ```
  <form method="post" action="/posts/<%= post.id %>" style='display: inline'>
    <input name= "_method" type="hidden" value="delete">
    <input type="submit" value="Delete" />
  </form>
  ```
  
## 9. Form Helpers
1. CSRF: Cross-Site Request Forgery is a type of attack on an application, it uses 
   hidden malicious code in one application to attack data in another application
   Example:
   ```
   <a href="http://example.com" name="example" onclick="www.our_app/posts/1/delete">...</a>
   ```
   * If such a link was clicked, that html event of onclick would fire off. The value in onclick would 
     get added to our cookies. If we were still logged into our app when we clicked the above link, then 
     that cookie would be sent to our application, and verified with our current session id. Clicking the 
     link above could then delete a post on our application without the user even realizing it.

  - How to prevent CSRF?
  Answer:
    Rails prevents such an attack with the use of an `authenticity_token`: a random string stored in our session.
    Every time a javascript or html based request is made, it is checked for an authenticity token.
    If the token sent with the request from a form does not match the one stored in application's session, 
    then an exception will be thrown.

    * set a hidden input element with a name of `authenticity_token` and a value that is set by the 
      `form_authenticity_token` method, which looks at the token saved in our session and returns it for use
  
  - form_tag Helpers:
  ```
  label_tag → <label></label>
    # takes one argument that sets the for attribute, as well as the content for that label
    
  text_field_tag → <input type='text'>
    # first argument of the text field and text area helpers sets the name and id attributes.
    The second argument sets what the content/value that will be used for that tag
    
  submit_tag → <input type='submit'>
    # takes one argument that sets the value of the submit tag
  ```
  
  - Parameter Naming Conventions and Mass Assignment
    * Any fields related to our post are in a nested hash
    ```
    1] pry(#<PostsController>)> params
    => {"utf8"=>"✓",
     "authenticity_token"=>"PSdbhGz0Cb2ic0PO2GwmNs9+3rSxLp0wNAVR6OHvGdIuk/5Icdba7yMuFA93/ssYR15hNyI3NVlwnYd0KQuP4A==",
     "post"=>{"title"=>"A New Post", "body"=>"Hello World", "author"=>"Alice Cooper"},
     "commit"=>"Create Post",
     "controller"=>"posts",
     "action"=>"create"}
    ```
    
    * mass assignment: is a name for when we use a group of values to update an object


# 10. Building Our Own Form Helpers
  - `my_form_tag`
    need to be aware of a number of different things:
    1. the path the <form> should submit to
    2. the HTTP verb the <form> uses
    3. the name attribute of each field in the <form>
    4. populating each field with a value, if needed
  
    ```
    <!-- app/views/posts/show.html.erb -->

    <div class="comments">

      <!-- ... -->

      <%= my_form_tag post_comments_path(@post.id) do %>

        <% unless @comment.new_record? %>
          <%= my_hidden_field_tag '_method', 'patch' %>
        <% end %>

        <%= my_label_tag 'Comment' %>
        <%= my_text_area_tag 'comment[body]', @comment.body %>
        <br /><br />

        <%= my_label_tag 'Author' %>
        <%= my_text_field_tag 'comment[author]', @comment.author %>
        <br /><br />

        <%= my_submit_tag %>
      <% end %>

    </div>
    ```
    
    * If we were to execute the block normally, like this:
    ```
    def my_form_tag(path, &block)
      attrs  = "method='post' action='#{path}'"
      fields = block.call # <- calling the block normally
      "<form #{attrs}> #{my_authenticity_token_field} #{fields} </form>".html_safe
    end
    ```
    will end up with something like this:
    ```
    <label>Comment:</label>
    <textarea name='comment[body]' value=''></textarea>
    
    <label>Your Name:</label>
    <input name='comment[author]' value='' type='text' />
    
    <input type='submit' value='Submit'>
    
    <!-- ^ Only the authenticity token field makes it into the <form>! -->
    
    <form method='post' action='/posts/1/comments'>
      <input name="authenticity_token" value="" type="hidden">
    </form>
    ```
    This happens because executing the ERB block results in its return being placed immediately into the 
    output HTML when the call occurs.
    So the capture implementation will give us a working <form>, to trap the block's return value in a variable,
    and then place it in the <form> string where it belongs

      
# 11. Unobtrusive Scripting
  1. Write a Dynamic Form With link_to
    Deleting a post or a comment currently needs a form so that we can use the `_method` trick to trigger a DELETE 
    action. Rails provides a way that we can do this simply with the link_to helper
  ```
  <%= link_to 'Delete', post_path(post.id), method: :delete, data: { confirm: "Are you sure want to delete '#{post.title}'?"} %>
  
  # render into
  <a data-confirm="Are you sure want to delete 'post_title_here'?" rel="nofollow" data-method="delete" href="..." >Delete</a>
  ```
  
  - "unobtrusive scripting": Javascript code that facilitates is not intertwined with the markup
    Rails monitors the data-method and data-confirm data attributes for special processing with a Javascript 
    library: jquery-rails

  2. Javascript Include Tag and CSRF meta tags
    `link_to` dynamic form is using Javascript, and when using Javascript to send a form, we will need to include 
    this csrf meta token
  

# 12. Render Responsive Views
  1. Layouts: extract common code that is used for several view templates to one location
    `yield` identifies where content from our view should be inserted into the enclosing layout. 

  2. Partials
    - extract common HTML/ERB code that is reused in various view templates to one location
    - place the common codes in different paths in "shared" and passing obj
  
  3. Options for using layout method
    - In the controller, we may specify a different layout (instead of the default one, application.html.erb) 
      for our views. It's also possible to set a specific layout for all actions in a controller.

  4. Flash Messages
    - consider flash as a hash that can store messages which can then be pulled out in the next HTTP request

# 13. Active Record Models
  1. Models
    | Model Name    | File Location and Name  | Database Table Name  |
    | ------------- |:-------------:| -----:|
    | Post    | app/models/post.rb | posts |
    | MoutainBike	 | app/models/mountain_bike.rb  | mountain_bikes |

   
# 14. Active Record
  - When you have a has_many :comments line in your model, Rails will define a method comments for you, 
    very similar to the comments method we had before, to retrieve all the comments related to the post.
  - when you have a belongs_to :post line in your Comment model, Rails will define the method post to 
    fetch you the post related to that comment.