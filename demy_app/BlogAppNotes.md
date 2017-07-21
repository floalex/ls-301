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