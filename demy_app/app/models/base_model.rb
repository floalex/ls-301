class BaseModel
  attr :errors
  
  def new_record?
    @id.nil?
  end
  
  def save
    return false unless valid?
    
    if new_record?
      insert
    else
      update
    end
    
    true
  end
  
  # a way get the right table name string
  def self.table_name
    # inside of a class method self is the class
    to_s.pluralize.downcase
  end
  
  def self.all
    # use it in SQL
    hashes = connection.execute("SELECT * FROM #{table_name}")
    hashes.map do |hash|
      new hash
    end
  end
  
  def self.find(id)
    record_hash = connection.execute("SELECT * FROM #{table_name} WHERE #{table_name}.id = ? LIMIT 1", id).first
    new(record_hash)
  end
  
  def destroy
    connection.execute("DELETE FROM #{self.class.table_name} WHERE #{self.class.table_name}.id = ?", id)
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