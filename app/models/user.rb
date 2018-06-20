class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence:true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  has_many :relationships 
  # , class_name: "Relationship" , foreign_key: "user_id"が省略されている。
  # source: :followはカラムの中でどのid(follow_id)を参照するか定義いている
  has_many :followings, through: :relationships, source: :follow
  
  # has_many :relationshipsとしたいが、上記定義済みのため、:reverses_of_relationshipと命名。クラスはRelationshipのため、
  # やっていることはrelationshipsと同一。
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user


  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    # relationshipがあればif文の前を実行する
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    # + [self.id]は自信を配列にして追加している。
    Micropost.where(user_id: self.following_ids + [self.id])
  end
end
