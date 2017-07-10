##1. Rails Summary
  - index: A technique that makes querying data a lot faster
  - no-sequal: document database in Mongo has key value pairs in giant hash

  - Model back form pattern
    * if save redirect_to else render
  
  - For non-model backed form, `redirect_to` for else becuase no object

##2. Followers/Followings
  - Relationships: `follower_id` and `leader_id`
  - Pick good names when defining the relationships for have_many association
  
  - UI
    1. Create the follow route and the follow/unfollow action/method in controller
      * Make sure to authenticate user for the follow/unfollow action
      * If user follows another user, `current_user.following_user << user`
      * A couple ways to implement the `unfollow` action
        1. Destroy the relationship: `Relationship.where(follower: current_user, leader: user).first.destroy`
    2. Create the follow timeline route and method
      * Statuses in an array and assign it to an instance variable
      * Iterate through `current_user.following_user`, then append `user.statuses.all` to the `@statuses`
      * Iterate through all the statuses with `status.body` in the view

##3. Modeling @mentions
  1. Create mentions route and the method in users controller
  2. Create mentions table: need `user_id` and `status_id`
  3. Create the mention model
    * Define the relationship with the user: belongs to user and status, user has many mentions
  4. After a status is created, inspect the status body
    * extract all @ occurences and match with existing username
      - User call backs in the user model: `after_save: extract_mentions`
      - In the extract method: use Regex to scan all the `@`
    * If username exists, create mention with user and status
      - If mention size > 0, iterate through all the mentions 
      - find the user in the iteration, icreate mention if username exists

##4. Display unread mentions
  1. Create migration: `add_column :mentions, :viewed_at, :datetime`
  2. Define the relationship in user model, use SQL syntax `viewed_at: NULL` to only querying the mentions not viwed yet.
  3. Show `num_unread_mentions` in the view
  4. In users controller, mark all the mentions read: `current_user.mark_unread_mentions!` in mention method
    * Define the `mark_unread_mentions` in user model
    * Define `mark_viewed` method in mention model with the `update` method from Rails
  
Difference between integration and unit test:
- integration: high level of the app
- unit: test for a particular method

##5. Twitter Boostrap, asset pipeline and Heroku
  - Boostrap: Give deveopers front end tools includeing HTML, CSS and jQuery to build the app without worrying UI
    * Be able to convert the pure HTML code to Ruby code in erb file
    * Use bootstrap-sass gem since
      1. The gem keeps updating
      2. Include all the bootstrap styles in the app

  - asset pipeline
  
  - Heroku
    * Need to do git init even if you don't want to push to github, then `git add .`, `git commit -m "initial commit"`
    * `cat .git/config` to see the config info 
    * `git push heroku master` to deploy to Heroku
    * Need to make sure bundler update and install
    * Need to run migration after pushing to Heroku: `heroku run rake db:migrate`
    * Restart Heroku: `heroku restart`
  
##6. Hashtags and retweets
  1. Create resources for hashtag
  2. Create hashtag controller for show
    - Use SQL to querying all the hashes
    - Put `link_hash_tag` method in appliction helper
  3. Add retweet post route and the link for every status
  4. Add retweet_id column in status table, define relationshiops with parent status