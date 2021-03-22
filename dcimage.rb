require 'mini_magick'

module Stegno
    class DCImage

        def initialize(coverImg, secretImg=nil, secretImgName=nil)
            @coverImg = coverImg
            @secretImg = secretImg
            @secretImgName = secretImgName

            @secretImgPixels = @secretImg.get_pixels if @secretImg
            @coverImgPixels = @coverImg.get_pixels

            @rgb = {
                "r"=>0, "g"=>1, "b"=> 2
            }
        end

        def encodeImage
            max_secretImg_y = @secretImg.height
            max_secretImg_x = @secretImg.width 

            (0..max_secretImg_y - 1).each{ |y|
                (0..max_secretImg_x - 1).each{ |x|
                    encodeLSBInPixelChannel('r', y, x)
                    encodeLSBInPixelChannel('g', y, x)
                    encodeLSBInPixelChannel('b', y, x)
                }
            }

            image = MiniMagick::Image.get_image_from_pixels(@coverImgPixels, [@coverImg.width, @coverImg.height], 'rgb', 8 ,'png')
            image.write('output.png')
        end

        def decodeImage
            max_coverImg_y = @coverImg.height
            max_coverImg_x = @coverImg.width
            
            decoded_pixels = []

            current_r_bin = ""
            current_g_bin = ""
            current_b_bin = ""

            (0..max_coverImg_y - 1).each{ |y|
                decoded_pixels.push([])
                (0..max_coverImg_x - 1).each{ |x|
                    current_r_bin += decodeLSBInPixelChannel('r', y, x)
                    current_g_bin += decodeLSBInPixelChannel('g', y, x)
                    current_b_bin += decodeLSBInPixelChannel('b', y, x)

                    if x % 8 == 0
                        r_value = current_r_bin.to_i(2)
                        g_value = current_g_bin.to_i(2)
                        b_value = current_b_bin.to_i(2)

                        decoded_pixels[y].push([r_value, g_value, b_value])

                        current_r_bin = ""
                        current_g_bin = ""
                        current_b_bin = ""
                    end
                }
            }
            image = MiniMagick::Image.get_image_from_pixels(decoded_pixels, [decoded_pixels[0].length, decoded_pixels.length], 'rgb', 8 ,'png')
            image.write('output1.png')
        end

        def encodeLSBInPixelChannel(channel, y, x)
            value = @secretImgPixels[y][x][@rgb[channel]]
            binary = conver8BitBinary(value)

            cover_x = x * 8

            current_bit = 0
            binary.each_char{ |b|
                if b == '1'
                    if isEvenNumber(@coverImgPixels[y][cover_x + current_bit][@rgb[channel]])
                        @coverImgPixels[y][cover_x + current_bit][@rgb[channel]] += 1
                    end
                elsif b == '0'
                    if !isEvenNumber(@coverImgPixels[y][cover_x + current_bit][@rgb[channel]])
                        @coverImgPixels[y][cover_x + current_bit][@rgb[channel]] -= 1
                    end
                end
                
                current_bit += 1
            }
        end

        def decodeLSBInPixelChannel(channel, y, x)
            value = @coverImgPixels[y][x][@rgb[channel]]
            binary = conver8BitBinary(value)
            return binary[7]
        end

        def isEvenNumber(num)
            return num % 2 == 0
        end

        def conver8BitBinary(num)
            binary = num.to_s(2)
            if binary.length < 8
                zeros = '0' * (8 - binary.length)
                return zeros + binary
            else
                return binary
            end
        end
    end
end