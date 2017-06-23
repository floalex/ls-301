module Sluggable
  extend ActiveSupport::Concern
  
  included do
    before_save :generate_slug!
    class_attribute :slug_column
  end
  
  def to_param
    self.slug
  end
  
  def generate_slug!
    the_slug = to_slug(self.send(self.class.slug_column.to_sym))
    obj = self.class.find_by(slug: the_slug) #self.class will be the model that includes the module
    count = 2
    # Make sure the obj exists and the obj objects are not the same
    while obj && obj != self
      the_slug = append_suffix(the_slug, count)
      # loop will stop with this condition
      obj = self.class.find_by(slug: the_slug)
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
  
  module ClassMethods
    def sluggable_column(col_name)
      self.slug_column = col_name
    end
  end
end