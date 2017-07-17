class Post
  attr_reader :id, :title, :body, :author, :created_at
  
  def initialize(attributes={})
    @id = attributes['id']
    @title = attributes['title']
    @body = attributes['body']
    @author = attributes['author']
    @created_at = attributes['created_at']
  end
  
  def self.find(id)
    post_hash = connection.execute("SELECT * FROM posts WHERE posts.id = ? LIMIT 1", id).first
    Post.new(post_hash)
  end
  
  def save
    insert_query = <<-SQL
      INSERT INTO posts (title, body, author, created_at)
      VALUES (?, ?, ?, ?)
    SQL
    
    connection.execute insert_query,
      params['title'],
      params['body'],
      params['author'],
      Date.current.to_s  
  end
  
  private
  
  def self.connection
    db_connection = SQLite3::Database.new 'db/development.sqlite3'
    db_connection.results_as_hash = true
    db_connection
  end
  
  def connection
    self.class.connection
  end
  
end