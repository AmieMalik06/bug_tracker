class ScreenshotUploader < CarrierWave::Uploader::Base
  storage :file # or :fog for cloud storage

  # Optional: store folder
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
