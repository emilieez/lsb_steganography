require 'mini_magick'

module Stegno
    class DCImage
        def initialize(coverImgPath, secretImgPath)
            @coverImg = MiniMagick::Image.open(coverImgPath)
            @secretImg = MiniMagick::Image.open(secretImgPath)
        end

        def getImgData
            pixels = image.get_pixels

            puts pixels[3][2][1] # the green channel value from the 4th-row, 3rd-column pixel
        end
    end
end