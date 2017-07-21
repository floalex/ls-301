class Comment
  attr_reader :id, :body, :author, :post_id, :created_at, :errors
  
  def initialize(attributes={})
    @id = attributes['id'] if new_record?
    @body = attributes['body']
    @author = attributes['author']
    @post_id = attributes['post_id']
    @created_at ||= attributes['created_at']
    @errors = {}
  end
  
  def new_record?
    @id.nil?
  end
  
  def valid?
    @errors['body'] = "Can't be blank" if body.blank?
    @errors['author'] = "Can't be blank" if author.blank?
    @errors.empty?
  end
  
  def self.all
    comment_hashes = connection.execute("SELECT * FROM comments")
    comment_hashes.map do |hash|
      Comment.new(hash)
    end
  end
  
  def self.find(id)
    comment_hash = connection.execute("SELECT * FROM comments WHERE comments.id = ? LIMIT 1", id).first
    Comment.new(comment_hash)
  end
  
  def destroy
    connection.execute("DELETE FROM comments WHERE comments.id = ?", id)
  end
  
  def save
    return false unless valid?
    
    if new_record?
      insert
    else
      # update # to be defined
    end
  end
  
  def insert
    insert_query = <<-SQL
      INSERT INTO comments (body, author, post_id, created_at)
      VALUES (?, ?, ?, ?)
    SQL
    
    connection.execute insert_query,
      @body,
      @author,
      @post_id,
      Date.current.to_s  
  end
  
  def post
    # This can be accomplished using an existing method
    Post.find(post_id)
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