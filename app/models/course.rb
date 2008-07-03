class Course < ActiveRecord::Base
  validates_presence_of :title, :description

  belongs_to :user
  belongs_to :community
  has_many :chapters, :dependent => :destroy

  alias_attribute :to_s, :title
  
  is_indexed :fields => ['title', 'description', 'community_id', 'draft']

  def draft_to_users?
    return self.draft?
  end
  
  #returns true if this is a draft
  def contains_drafts
    for chapter in chapters
      return true if chapter.draft || chapter.contains_drafts
    end
    return false
  end
  
  def contains_premium
    for chapter in chapters
      for lesson in chapter.lessons
        return true if lesson.content.premium
      end
    end
    return false
  end
  
  def contains_registered
    for chapter in chapters
      for lesson in chapter.lessons
        return true if lesson.content.registered
      end
    end    
    return false
  end
  
end
