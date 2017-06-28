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
7. Run `heroku restart` to restart the app after you migrate 
8. Other helpful heroku commands:
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
      
## 8. Add routes for posts
  Put `resources :posts` in your routes.rb file.

  Go into terminal and type `rake routes` to verify that all 7 routes are created. 
  Prevent the 'delete' route from being accessed, since we won't have the ability to delete posts in our application.

  You can now also navigate your browser to "localhost:3000/rails/info" to see routing information. 
  Note that you need to start the rails server first.

## 9. Add PostsController
  Create a PostsController that can handle the index and show routes.
  - display all the posts in index. `@posts = Post.all`
    * create index page view for all the posts. Each post should have title, description,
      creator name, created at and comments link
    * add post's categories in the view, it should be above the title
  - add `show` method in the controller
    * create individual post view
  - extract common codes to partials 

## 10. Complete Post Actions
  Create all the typical actions for the Post resource (index, show, new, create, edit, update).
  Use model backed forms. 
  Add a validation and make sure the validation fires and display on the template.
  
  Extract that template to a partial. The partial is actually being used by 4 actions: new, create, edit and update.
    - keep in mind that view templates' dependencies(mostly, instance variables) must be set up correctly 
      in all actions that render that template. Be aware of the edge cases.
    * `new_record` is an ActiveRecord method that we can call and see if the object is new in database

## 11. New Category form
  Create a new category model-backed form, with validations.
  You'll need to add a route, create controller/actions and view templates.
  Extract the post into post partial.
  
  Since both the new category and post forms display validation errors, extract that bit of template code 
  to a partial, so you can reuse that logic
  * pass the obj object for different objects

## 12. New comment
  On the show post page, display a model backed comment creation form.
    - create a newsted resource to support a nested comment creation url (eg, HTTP POST request to /posts/:post_id/comments)
    - create a newsted model backed form view with validations
    - create a CommentsController#create action, remember to set up parent object
    - render back to the form submitted from when the new comment can't be saved

## 13. Select categories on new/edit post form & Show Category
  1. On the post form, expose either a combo box or check boxes to allow selection of categories for this post.
  - Hint: use the category_ids virtual attribute. It will return array format like [1, 2]
  
  2. Show Category page
  - After your posts are associated with categories, display the categories that each post is associated with.
  - When clicking on the category, take the user to the show category page where all the posts associated with that category

## 14. Use Rails helpers to fix the url format as well as output a more friendly date-time format

## 15. `has_secure_password` and authentication
  Set up the User model to use `has_secure_password`. 
  Note that you'll need to add "gem 'bcrypt-ruby', '~> 3.0.0'" to the Gemfile to play well with the older Rails version
  Add password digest columns in users table
  Add `validations: false` on `has_secure_password` so we don't have to confirm the password again
  
  Authentication: 
  - Create the routes manually for the login/out
  - Create session controller and corresponding views for the login/out feature.
    * Use non-model backed form as we don't have session model
  - Make sure to create the appropriate helper methods to selectively hide elements on the template when 
    logged in/not logged in (eg, the create post form, etc)
  - use before action to prevent unauthenticated users from accessing certain controller actions (eg, create post action, etc).
  - assign the creator to the current_user when creating new posts or comments
  - Fix any data integrity issues in the database, like missing user_id values in the foreign key columns of the posts table

## 16. New user registration
  - Add resources to users in "routes" for necessary methods
  - Create users controller for registration
  - Create a new user form to register new users to your application.
  - how to automatically log them in after registration?
    * set the session when saving the user in registration

## 17. Edit/Show User Profile
  - add a btn group for users actions in navagiation
  - create the show and edit user pages
  - Try to re-use the partials for the comments part
  - create the tabs for displyaing all the posts, and all the comments in user's profile page
  - it's different from the comment partial on the show post page and user show page
    * pass in an additional parameter to the comment partial
      * turn the parameter on in user's profile page, turn it off in post show page
  - require same user when edit and update

## 18. Polymorphic Vote
  - Generate migration for votes; Create a polymorphic votes table, along with a polymorphic Vote model
    * Use boolean to keep track of the up/down vote
    * Need user id foriegn key to keep track of the creator
    * votable id and type(polymorphic true)
  - Create 1:M polymorphic association between Vote/Comment and Vote/Post. Just focus on the model layer right now.
  - Use polymorphic associations to add voting capability to posts(routes, actions, views, etc)
  - Same as for posts, build capability to vote on comments
  - Prevent voting if user is not authenticated, also don't show the voting arrows if not logged in
  - Don't allow the same user to vote multiple times on the same comment/post
    * Add "scope" to the validation

## 19. Add Ajax to voting
  - Rails' built-in functionality for SJR (server-generated javascript response). 
  - This is in contrast to UJS (unobtrusive javascript we saw in the Ruby course).

## 20. Add slugs to Post
  - Use the Post's title attribute to generate a new column called slug, which will be a 
    unique, SEO friendly identifier we can use in URLs, and can hide database data.
  - Difference between `before_create` and `before_save`
    * `before_create`: Only save it once in ActiveRecord
    * `before_save`: save the changes every time we change the attribute
  - After adding the new `slug` attribute in ActiveRecord, need to go to console to "save" all the objects again
    * like this: `Post.all.each { |post| post.save }`
  - Add similar slugs to User and Category
  - Make our slugging code more robust
    * Use regex to handle characters that are not letters or numbers
    * When have duplicate slugs, loop through them and make each one unique 
    * To make each slug unique, append a number(suffix) for the duplicate slugs
      - If the slug already has suffix, make sure don't append more suffix

## 21. Use module
  - Extract the common votes related code from the models into a module that you can mixin.
  - Let Rails auto load the module by adding `config.autoload_paths += %W(#{config.root}/lib)` in "config/application.rb"
  - Using `ActiveSupport::Concern` can write cleaner code, at the core it is using metaprograming
  
  - For sluggable module: require a little meta-programming, more difficult
    - Since the column name for difference classes are not the same, need to call a method to set the parameter: sluggable_column
    
  - Extract the common codes into gem
    * Create a new folder for the gem
    * put the logic under lib
    * use `gem build filename.gemspec`
    * `gem push newcreatefile.gem` to rubygem.org
  
* Warning: Make sure the file name, gem name and the `include xxx` in model need to be all matched to make the gem works in the app
  - If don't put "voteable" in front of the file and gem name, Rails couldn't find it in the app

##22. Simple Admin roles
  - Build a simple admin role so that only admins can create new categories.
    * Add the authorization roles logic to the User model
    * Modify the users table to add the roles
    * Extract the aceess deny common codes to one method in controller
  
  - Now that we have roles, implement a rule where only the creator or an admin can edit a post object.

##23. Time Zones
  - create a new column to allow users to display all times in the application in the user specified time zone.
    1. Set/overwrite the default time zone in "application.rb"
      - `rake time:zones:all | grep US` will display all the US time zone in terminal
    2. Add time zone column to the users table, the type is gonna be "string"
    3. Add the time zone field in the user's form in user view, user drop down feature, set the default time zone to eastern
      * Make sure the whitelist the time zone field in users controller
    4. Use `in_time_zone` to update the time in helper method 

##24. Two factor auth with Twilio(optional)
  Thinking process:
  1. phone column and pin column
  2. Change login logic
    a. After succesful login, is phone number present?
      i. no -> normal login
      ii. yes
        1. generate a pin number(save to db, do not show user)
        2. send it off to Twilio to sms to phone
        3. show a form to enter the pin
  
  Actual Steps:
  1. `rails generate migration add_two_factor_columns`
  2. Add the form field for phone:
    ```
    <%= f.label :phone, "Phone Number <small>(numbers only)</small>".html_safe %>
    <%= f.text_field :phone, maxlength: 9 %>
    <%= link_to '#', id: 'two_factor_phont' do %>
      <i class='icon-question-sign'></i>
    <% end %>
    ```
  3. Add phone number in users_params in the users controller
  4. In session controller, add the codes below in the "create method" after user.authenticate:
    ```
    if user.twofactor_auth?
      session[:two_factor] = true
      user.generate_pin!
      user.send_pin_to_twilio
      redirect_to pin_path
    else
    end
    ```
    
    Also add the `pin` method in the session controller:
    ```
    def pin
      access_denied if session[:two_factor].nil?
      
      if request.post?
        user = User.find_by(pin: params[:pin])
        if user
          user.remove_pin!
          login_users!(user)
        else
          flash[:error] = "Sorry something went wrong"
          redirect_to pin_path
        end
      end
    ```
  5. Add the `two_factor_auth?`, `generate_pin!` in user model:
    ```
    def two_factor_auth?
      !self.phone.blank?
    end
    
    def generate_pin!
      self.update_column(:pin, rand(10 ** 6)) # random 6 digit number
    end
    
    def remove_pin!
    self.update_column(:pin, nil)
    end
    
    def send_pin_to_twilio
      # copy the codes from Twilio website
    end
    ```
  6. Add the necessary routes in route file
    ```
    get '/pin', to: 'sessions#pin'
    post '/pin', to: 'sessions#pin'
    ```
  7. Add the pin template in session view
  8. Install Twilio in the app and require the file

##25. Pagination
  - Set PER_PAGE setting
  - Change the code in Posts index method
  - pages? - (num of all posts) / (posts per page)
  - page 1 -> offset: 0, shows: 1-3
  - page 2 -> offset: 3, shows: 4-6