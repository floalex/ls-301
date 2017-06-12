**1) What's the difference between rendering and redirecting? What's the impact with regards to instance variables, view templates?**
Rendering displays a view template that accesses the instance variables available in that action. Therefore, instance variables must 
be declared in that action before the render will work. Redirecting will send a new request to the browser based on the route path 
that was provided. In this case, the instance variables in that action are not related to the redirected view.

**2) If I need to display a message on the view template, and I'm redirecting, what's the easiest way to accomplish this?**
You can use `flash`. It saves the message with a session. The message will be displayed on your next action and will be removed after that.
```
flash[:message] = 'Your account was created.'
redirect_to :back
```

**3) If I need to display a message on the view template, and I'm rendering, what's the easiest way to accomplish this? **
When rendering and you want to quickly display a message on the view template, we can use `flash.now`.
Whatever message you pass to `flash.now` will be displayed in the same render request.

**4) Explain how we should save passwords to the database. **
We can use the has_secure_password method in our model to save passwords to our database. This allows us to save the 
passwords through a "1-way hash", meaning the hash of password strings will each turn into long, undecipherable tokens. In our 
database, we also need to create a password_digest column to keep track of the hash tokens (aka "digest"). Our password strings 
should never be stored within our application, they should only be digested. In order for our password strings to be 
encrypted/decrypted, make sure to have the bcrypt-ruby gem installed. With this gem installed, we are able to authenticate 
submitted password parameters by encrypting them into digests and see if they match our stored digests.

**5) What should we do if we have a method that is used in both controllers and views? **
We should declare the method in the application_controller.rb file. 
In order to have the method work in views as well, make sure to also list it as `helper_method :a_method`.

**6) What is memoization? How is it a performance optimization? **
Memoization allows us to enhance performance because we are caching the result of a method call instead of calling it every 
single time. This is a good technique whenever the result is the same every time. Instead of running the method and hitting the 
database every time per request, we can store the first result as an instance variable. By doing so, it will initially hit the database 
only once to get the stored valued and will optimize our performance since we can refer to the instance variable instead of calling 
the method again.
`@current_user ||= User.find(session[:user_id]) if session[:user_id]`

**7) If we want to prevent unauthenticated users from creating a new comment on a post, what should we do? **
We need two methods in the application_controller.rb file to determine if we have an authenticated user and if they are 
logged in. After that, we can use that method in an if/else statement in the view. If the user is logged in or authenticated, then the 
form to create a new comment will appear. We also need to include a before_action in our controller, so that if the user isn't 
authenticated or logged in, an error message will appear.

**8) Suppose we have the following table for tracking "likes" in our application. How can we make this table polymorphic? Note that the "user_id" foreign key is tracking who created the like.**

id | user_id | photo_id	| video_id | post_id
--- | --- | --- | --- | ---
1 | 4 |	  | 12 | 
2 | 7 |	  |    | 3
3 | 2 | 6 |    | 


id | user_id | likeable_type	| likeable_id
--- | --- | --- | --- 
1 | 4 |	Video | 12 
2 | 7 |	Post  | 3 
3 | 2 | Photo | 6

**9) How do we set up polymorphic associations at the model layer? Give example for the polymorphic model (eg, Vote) as well as an example parent model (the model on the 1 side, eg, Post). **
```
# Polymorphic association at the Vote model layer
class Vote < ActiveRecord::Base
	belongs_to :voteable, polymorphic: true
end
```

```
# Polymorphic association on a parent model layer (Post)
class Post < ActiveRecord::Base
	has_many :votes, as: :voteable
end
```

**10) What is an ERD diagram, and why do we need it? **
An ERD diagram stands for an Entity-Relationship Diagram. It is recommended to spend quality time drafting out an ERD diagram 
before development. This is very important when building our application, because it lays out the blueprint of our models, the 
associations between them, and also the attributes involved. During development, we often refer to the ERD to build our model 
associations and our database schema.
