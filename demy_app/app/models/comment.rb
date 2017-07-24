class Comment < BaseModel

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

end