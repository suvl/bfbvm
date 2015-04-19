::Refinery::News::Item.class_eval do
  # Whitelist the :image_id parameter for form submission
  #attr_accessible :image_id
  belongs_to :image
end