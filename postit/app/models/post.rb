class Post < ActiveRecord::Base
  include Voteable
  
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :comments
  has_many :post_categories
  has_many :categories, through: :post_categories
  
  validates :title, presence: true, length: { minimum: 5 }
  validates :url, presence: true, uniqueness: true
  validates :description, presence: true
  
  before_save :generate_slug!
  
  def to_param
    self.slug
  end
  
  def generate_slug!
    the_slug = to_slug(self.title)
    post = Post.find_by(slug: the_slug)
    count = 2
    # Make sure the post exists and the post objects are not the same
    while post && post != self
      the_slug = append_suffix(the_slug, count)
      # loop will stop with this condition
      post = Post.find_by(slug: the_slug)
      count += 1
    end
    self.slug = the_slug.downcase
  end
  
  def append_suffix(slug, count)
    if slug.split("-").last.to_i != 0
      # get rid of the previous suffix first before appending the new one
      # e.g "new-post-1" next: "new-post-2"
      slug.split("-").slice(0...-1).join("-") + "-" + count.to_s
    else
      slug + "-" + count.to_s
    end
  end
  
  def to_slug(name)
    str = name.strip
    str.gsub!(/\s*[^A-Za-z0-9]\s*/, "-")
    str.gsub!(/-+/, "-")
    str.downcase
  end
end