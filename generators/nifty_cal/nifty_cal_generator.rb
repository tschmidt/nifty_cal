class NiftyCalGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      
      # Add a stylesheet directory for NiftyCal
      style_dir = "public/stylesheets/nifty_cal"
      m.directory style_dir
      m.file File.join('modern.css'), File.join(style_dir, "modern.css")
    end
  end
end