class Version < ActiveRecord::Base
  attr_reader :sections

  after_create :generate_markdown

  belongs_to :article
  belongs_to :updating_author, class_name: :"User"
  has_many :categorizations
  has_many :categories, through: :categorizations

  ######  class   #######


  def self.new_version(author, article, arguments)
    v = Version.new(arguments)
    v.updating_author = author
    v.article = article
    return v
  end


  #####  instance   #######

  def generate_markdown
    @sections = self.get_sections
    @markdown_content = self.get_newlines
    @markdown_content = self.get_bold_text
    @markdown_content = self.get_italic_text
  end

  def get_sections
    @markdown_content = self.content
    @sections = []
    new_section_data = @markdown_content.match(/#.+\n/)
    section_number = 0
    while new_section_data
      title = new_section_data.to_s
      title[0] = ''
      @sections.push(title)
      start_index = @markdown_content.index(/#.+\n/)
      title_length = new_section_data.to_s.length
      end_index = start_index + title_length - 1
      @markdown_content[end_index] = "</h3>"
      @markdown_content[start_index] = "<h3 class=\"section\" id=\"#{section_number}\">"
      section_number += 1
      new_section_data = @markdown_content.match(/#.+\n/)
    end
    @sections
  end

  def get_newlines
    @markdown_content = @markdown_content.gsub(/\n/, "<br><br>")
  end

  def get_bold_text
    index = @markdown_content.index(/\*/)
    counter = 1
    while index
      (counter % 2 == 1) ? @markdown_content[index] = "<strong>" : @markdown_content[index] = "</strong>"
      index = @markdown_content.index(/\*/)
      counter += 1
    end
    @markdown_content
  end

  def get_italic_text
    index = @markdown_content.index(/\_/)
    counter = 1
    while index
      (counter % 2 == 1) ? @markdown_content[index] = "<em>" : @markdown_content[index] = "</em>"
      index = @markdown_content.index(/\_/)
      counter += 1
    end
    @markdown_content
  end

end
