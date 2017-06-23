# Using concerns
module Voteable
  extend ActiveSupport::Concern
  
  included do
    has_many :votes, as: :voteable
  end
  
  def total_votes
    self.up_votes - self.down_votes
  end
  
  def up_votes
    self.votes.where(vote: true).size
  end
  
  def down_votes
    self.votes.where(vote: false).size
  end
end

# Using normal metaprogramming
=begin
module Voteable
  def self.included(base) # base class is the parent class
    base.send(:include, InstanceMethods)  # the object can use the instance methods directly in the console
    base.extend ClassMethods # Extend so that the model class can use the class methods
    base.class_eval do # fire class method
      my_class_method
    end
  end
  
  module InstanceMethods
    def total_votes
      self.up_votes - self.down_votes
    end
    
    def up_votes
      self.votes.where(vote: true).size
    end
    
    def down_votes
      self.votes.where(vote: false).size
    end
  end
  
  module ClassMethods
    def my_class_method
      has_many :votes, as: :voteable
    end
  end
  
end
=end