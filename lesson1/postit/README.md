== Getting Started

1. Make sure you have rails version 4. Type "rails -v" to make sure.
2. From this project directory, do "bundle install --without production"
3. To start the server "rails server".
4. Navigate your browser to localhost:3000.


== Setting up with Git

1. Instantiate this directory as a git repository with "git init".
2. Go to github.com, create a new repository, then follow instructions on how to add a remote repository that links to github.
3. Remember, you have to "git add" changes to ready it for a commit, then "git commit" to commit those changes locally, then "git push origin master" to push it to the remote "origin" repository, which is the previously created github.com repository.

== Deploying to Heroku

1. Download the Heroku Toolbelt.
2. Go to Heroku.com and register.
3. Issue "heroku login" to authenticate, with the credentials from previous step. Make sure it's a git repository, by issuing "git init", and also "git add", "git commit" your files.
4. Then "heroku create" to create this app on heroku. This command also adds a "heroku" remote repository that you can push to.
5. To deploy, issue "git push heroku master".
6. You may need to run migrations on heroku afterwards, with "heroku run rake db:migrate".
7. Other helpful heroku commands:
  - heroku logs
  - heroku logs -t
  - heroku rename
  - heroku restart
  - heroku run console
  - heroku help

== Step by Step how the project build

## 1. Set up Post model
  1. First, create a migration to modify the database. In this migration, we want 
     to create the table. Rails migrations are the only place where we want to use 
     generators. Issue this command from the terminal within your project directory: 
     `rails generate migration create_posts`
  2. Open the newly created migration file in your code editor, and take a look at 
     the migration file. Use the `create_table` method to create the necessary table 
     and columns. We want: a `url` and `title`, which should both be strings and a 
     `description` which should be text. Also `user_id` should be integer, `timestamps`
  3. From the terminal again, issue this command: `rake db:migrate` (you may need to 
     do rake db:create first, if you're using mysql or postgres). If you're getting 
     a rake error, you can try adding `bundle exec` before the rake command.
  4. Then take a look at your database and see that you have a posts table, with 
     three columns: url, title and description.
  5. Create a Post model file: under app/models directory, create a post.rb file 
     put `class Post < ActiveRecord::Base; end`
  6. Open rails console, and create your first Post object: 
     `Post.create(title: "My first post", description: "I sure hope this works!", url: "www.yahoo.com")` 
     Verify by looking at your database that this worked.

## 2. User model
  Same as the Post model, except the User model should have a username column of type string.

## 3. 1:M between User and Post
  two step process:
  1. First, we need to modify the database to create a new foreign key column on the posts table 
     to support the one to many association. Remember, the foreign key column always goes on the 'many' side.
     Hint: generate a migration file, then use Rails migration syntax to create a new column.
  2. Declare the associations in the models.
  
  * Verify that your associations are set up correctly.
    1. Create some data to populate the posts and users tables.
    2. Associate the data by setting the foreign key column in posts table with a user id.
    3. see if you can traverse the association:
    4. Example:
    ```
    post = Post.find(1)
    post.user
    post.user.username
    ```
## 4. Comment model
  Create a Comment model, with a body attribute to store the comment's text. 
  It can't be a "string" because strings have limited size restriction, so it has to be of type "text".
  Note that the Comment model has two associations:
    - one with the User model to track who created it
    - another with the Post model to track which post this comment is for.
    - need two 1:M associations

## 5. Comment associations
  Set up the two 1:M associations for the Comment model, and verify in rails console.
  - with User, to track who created the comment
  - with Post, to track what this comment is about

## 6. Category model
  The Category model should only have a name attribute.
    - `rails generate migration create_categories`
    - add name in string and timestamps in the table

## 7. M:M between Post and Category
  Use "has_many through" to set up a many to many association between Post and Category models.
    - `rails generate migration create_post_categories`
    - add two integer ids with timestamps in the table

  Note that you'll need a model backed join table to do this. You'll need to
    - modify the database schema
    - set up the associations in the models. Verify via rails console that this worked, 
      and that you can assign categories to posts, and iterate through a category's posts
      and vice versa (iterate through a post's categories).