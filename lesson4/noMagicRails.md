##1. Rails is fragile
  - Follow convention and understand the basics will be fine

##2. Show Post
  - Find the particular post through id/slug param to show the post
    * non Rails way
    * to show post:
      1. Read database: `db = SQLite3::Database.new 'db/development.sqlite3`
      2. From the database file, find the first post with the id to get the post with SQL way
      3. create the new `post` object with the results from the database
      4. render the `show_post` view file by passing in the post object 
    * to create new post:
      1. user `db.execute` to insert new row into the SQL table with the params 
      2. flash message implementation: `session[:message] = 'string'` then set it back to nil in view
        - Rails will keep track of the session message with the flash method
      3. redirect to different route

## Clean codes
  - Move the codes related to database to the model layer, and keep the controller codes clean
    * Object.find
    * Object.create
  
  - How to implement the `save` method in Rails?
    * first, verify attributes are valid
      * return false if invalid
    * else, insert and return true
    * for update, if the object is new(`id.nil?`), insert it
    * else call update
  
  - To implement the `valid?` method
    * execute a list of validations
    * sets "errors" if there are any validations 
    * return whether errors empty
  
## Final Clean up
  
