module ProfilePhoto
  
  # require 'sequel/extensions/inflector'
  
  attr_accessor :photo
  
  def photo_url(type = :thumb, default = "")
    photo_exists?(type) ? "/photos/#{self.class.to_s.underscore.pluralize}/#{self.id}/#{type}.jpg" : default
  end
  
  def photo_exists?(type = :thumb)
    File.exists?(photo_path(type))
  end
  
  def photo_dir
    settings.root + "/public/photos/#{self.class.to_s.underscore.pluralize}/#{self.id}"
  end
  
  def photo_path(type = :thumb )
    photo_dir + "/#{type}.jpg"
  end
  
  def remove_photo!
    FileUtils.rm_rf photo_dir if File.exists?(photo_dir)
  end
  
  def generate_files(original, photo_owner)

    dir = photo_dir
    puts "Making #{dir}"
    FileUtils.mkdir_p(dir) unless File.exist?(dir)

    pic = QuickMagick::Image.read(original).first
    pic.save("#{dir}/orig.jpg") unless original == "#{dir}/orig.jpg"

    w = pic.width
    h = pic.height
    
    sizes = photo_owner.class.sizes rescue {
      :thumb  => { :width => 60, :height => 60 },
      :profile   => { :width => 120, :height => 120 }
    }

    sizes.each do |t, geom|

      if geom[:width] && geom[:height]
          
        newgeom = "#{geom[:width]}x#{geom[:height]}"
          
        pic.thumbnail("#{newgeom}^") if w > geom[:width] && h > geom[:height]
        pic.append_basic("-background white -gravity center -extent '#{newgeom}'")
      
      end

      pic.append_basic "-quality #{geom[:quality] || 80}"
      pic.append_basic "-strip"
      pic.save photo_path(t)
      
      pic.revert!

    end

  end
  
  
  # =========
  # = Hooks =
  # =========
  
  def before_save
    super
    process_upload! if self.photo
    true
  end
    
  def process_upload!
    if photo
      generate_files photo[:tempfile].path, self
    end
  end
  
  def after_destroy
    super
    remove_photo!
  end
  
end