module ApplicationHelper
  def nasturtium_image_exists?
    File.exist?(Rails.root.join("app", "assets", "images", "nasturtiums.png"))
  end
end
