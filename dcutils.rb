module Stegno
    class DCUtils
        def initialize(coverImg, secretImg, secretImgName, mode)
            @coverImg = coverImg
            @secretImg = secretImg
            @secretImgName = secretImgName
            @mode = mode
        end

        def start
            if @mode == 'encode'
                encode()
            elsif @mode == 'decode'
                decode()
            end
        end

        def encode
            dcImage = Stegno::DCImage.new(@coverImg, @secretImg, @secretImgName)
            dcImage.encodeImage()
        end

        def decode(pixel)
        end
    end
end