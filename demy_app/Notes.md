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