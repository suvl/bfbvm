module Refinery::News::Admin
  ItemsController.class_eval do
    private
      def item_params
        params.require(:item).permit(:title, :body, :content, :source, :publish_date, :expiration_date, :image_id)
      end
  end
end