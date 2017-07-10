class Status < ActiveRecord::Base
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'
  belongs_to :parent_status, class_name: 'Status', foreign_key: 'retweet_id'

  validates :creator, presence: true
  validates :body, presence: true, length: {minimum: 5}

  after_save :extract_mentions

  def extract_mentions
    mentions = self.body.scan(/@(\w*)/)
    if mentions.size > 0
      mentions.each do |mention|
        m = mention.first
        user = User.find_by username: m
        if user
          Mention.create(user_id: user.id, status_id: self.id)
        end
      end
    end
  end

end
