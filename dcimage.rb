require 'mini_magick'

module Stegno
    class DCImage

        def initialize(coverImg, secretImg, secretImgName)
            @coverImg = coverImg
            @secretImg = secretImg
            @secretImgName = secretImgName

            @secretImgPixels = @secretImg.get_pixels
            @coverImgPixels = @coverImg.get_pixels

            @rgb = {
                "r"=>0, "g"=>1, "b"=> 2
            }
        end

        def encodeImage
            max_secretImg_y = @secretImg.height
            max_secretImg_x = @secretImg.width 

            new_pixels = ""

            (0..max_secretImg_y - 1).each{ |y|
                (0..max_secretImg_x - 1).each{ |x|
                    encodeLSBInPixelChannel('r', y, x)
                    encodeLSBInPixelChannel('g', y, x)
                    encodeLSBInPixelChannel('b', y, x)
                }
            }

            image = MiniMagick::Image.get_image_from_pixels(@coverImgPixels, [@coverImg.width, @coverImg.height], 'rgb', 8 ,'jpg')
            image.write('output.jpg')
        end

        def encodeLSBInPixelChannel(channel, y, x)
            value = @secretImgPixels[y][x][@rgb[channel]]
            binary = value.to_s(2)

            binary.each_char{ |b|
                if b == '1'
                    if isEvenNumber(@coverImgPixels[y][x][0])
                        @coverImgPixels[y][x][@rgb[channel]] += 1
                    end
                elsif b == '0'
                    if !isEvenNumber(@coverImgPixels[y][x][0])
                        @coverImgPixels[y][x][@rgb[channel]] -= 1
                    end
                end
            }
        end

        def isEvenNumber(num)
            return num % 2 == 0
        end
    end
end