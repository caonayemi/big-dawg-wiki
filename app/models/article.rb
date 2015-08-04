class Article < ActiveRecord::Base

  COMMON_WORDS_LIST = ['the', 'of','and','a','to','in','is','you','that','the','was','for','on','are','as','with','his','they','I', 'at','be','this','have','from','or','one','had','by','word','but','not','what','all','were','we','when','your','can','said', 'there', 'use', 'an', 'each', 'which', 'she', 'do', 'how', 'their', 'if', 'will', 'up', 'other', 'about', 'out', 'many', 'then', 'them', 'these', 'so', 'some', 'her', 'would', 'make', 'like', 'him', 'into', 'time', 'has', 'look', 'two', 'more', 'write', 'go', 'see', 'number', 'no', 'way', 'could', 'people', 'my', 'than', 'first', 'water', 'been', 'call', 'who', 'oil', 'its', 'now', 'find', 'long', 'down', 'day', 'did', 'get', 'come', 'made', 'may', 'part' ]

  after_create :set_slug

  has_many :versions
  # no user model yet....
  belongs_to :orig_author, class_name: :"User"
  has_many :categorizations, through: :versions
  has_many :categories, through: :categorizations

  def to_param
    self.slug
  end

  def set_slug
    self.slug = self.title.downcase.split.join("-") + "-" + self.id.to_s
    self.save
  end

  def self.match_id(slug)
    id_matcher = /\-([0-9]+)\z/
    match_group = slug.match(id_matcher)
    found_id = match_group[1].to_i
  end



  def self.search(word)
    return_ary = []

    self.all.each do |article|
      no_match = [word] - article.search_words
      unless no_match.any?
        return_ary << article
      end
    end

    return_ary
  end

  def current_version
    self.versions.find_by(is_most_recent: false) #true)
  end

  def self.recent_articles
    Article.all.map(&:current_version)

  end

  # self.all.select do |article|
  #   article.search_words

  # end

  def key_words
    self.title.downcase.split - COMMON_WORDS_LIST
  end

  def search_words
    self.categories.map{|c| c.name.downcase } + key_words
  end


end
