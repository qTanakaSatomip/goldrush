class HelpController < ApplicationController
  skip_before_filter :login_required

  def index
    @page_title = '[使用方法説明]'
  end

  def terms
  end

  def privacy
  end

end
