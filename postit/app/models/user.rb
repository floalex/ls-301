class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  has_many :votes
  
  has_secure_password validations: false
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, length: {minimum: 5}
  
  before_save :generate_slug!
  
  def to_param
    self.slug
  end
  
  def generate_slug!
    the_slug = to_slug(self.username)
    user = User.find_by(slug: the_slug)
    count = 2
  
    while user && user != self
      the_slug = append_suffix(the_slug, count)
      # loop will stop with this condition
      user = User.find_by(slug: the_slug)
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