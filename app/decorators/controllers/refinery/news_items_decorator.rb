module Refinery::News
  ItemsController.class_eval do
    helper ApplicationHelper

    def find_published_news_items
      @items = Item.published.translated.paginate :page => params[:page],
                                                  :per_page => 5
    end


  end
end