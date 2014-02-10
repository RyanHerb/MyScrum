# ===================================================
# = Patch for QuickMagic to reoder the command line =
# ===================================================

module QuickMagick

  class Image

    # The command line so far that will be used to convert or save the image
    def command_line
      %Q< "(" #{QuickMagick.c(image_filename + (@pseudo_image ? "" : "[#{@index}]"))} #{@arguments} ")" >
    end

  end

end
