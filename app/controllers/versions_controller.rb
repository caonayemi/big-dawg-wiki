class VersionsController < ApplicationController

  def new
    if current_user

      @display = VersionDisplayObject.new(params[:article_title])
      @display.set_current_version
      @display.set_sections_and_markdown

    else
      redirect_to "/"
    end
  end


  def create
    if current_user
      slug = params[:article_title]
      @display = VersionDisplayObject.new(slug)

      version = Version.new(version_params)
      version.updating_author = current_user
      version.article = @display.article

      version.categories = Category.parse_categories_from_string(params[:categories])

      good = version.save

      @display.version= version

      if good

        redirect_to "/articles/#{@display.article.to_param}/versions/#{version.id}"
      else
        @display.errors = version.errors.full_messages
        render :"views/versions/new"
      end

    else
      redirect_to "/"
    end
  end

  def edit
    @version = Version.find(params[:id])
    if (@version.updating_author == current_user && @version.is_published == false)|| current_user.permission_level == 'big_dawg'
      render :"versions/edit"
    else
      redirect_to "/articles/#{@version.article.to_param}/versions/#{@version.id}"
    end

  end

  def update
    @version = Version.find(params[:id])
    @version.update(version_params)
    redirect_to "/articles/#{@version.article.to_param}/versions/#{@version.id}"
  end

  def show
    @version = Version.find(params[:id])
    @sections = @version.get_sections
    @categories = @version.categories
    @markdown_content = @version.generate_markdown
  end

  def publish
    @version = Version.find(params[:id])
    @version.is_published = true
    @version.article.versions.each do |version|
      version.is_most_recent = false
      version.save
    end
    @version.is_most_recent = true
    @version.save
    redirect_to "/articles/#{@version.article.to_param}"
  end

  def version_params
    params.require(:version).permit(:content, :footnotes)
  end

end
