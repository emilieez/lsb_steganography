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

            nth_secret_pix = 0

            (0..max_secretImg_y - 1).each{ |y|
                (0..max_secretImg_x - 1).each{ |x|
                    encodeLSBInPixelChannel('r', y, x, nth_secret_pix)
                    encodeLSBInPixelChannel('g', y, x, nth_secret_pix)
                    encodeLSBInPixelChannel('b', y, x, nth_secret_pix)

                    nth_secret_pix += 1
                }
            }

            image = MiniMagick::Image.get_image_from_pixels(@coverImgPixels, [@coverImg.width, @coverImg.height], 'rgb', 8 ,'png')
            image.write('output.png')
        end

        def decodeImage
            max_coverImg_y = @coverImg.height
            max_coverImg_x = @coverImg.width
            
            decoded_pixels = [[]]

            current_r_bin = ""
            current_g_bin = ""
            current_b_bin = ""

            decoded_row_num = 0

            (0..max_coverImg_y - 1).each{ |y|
                (0..max_coverImg_x - 1).each{ |x|
                    current_r_bin += decodeLSBInPixelChannel('r', y, x)
                    current_g_bin += decodeLSBInPixelChannel('g', y, x)
                    current_b_bin += decodeLSBInPixelChannel('b', y, x)

                    if current_r_bin.length && current_b_bin.length && current_g_bin.length == 8
                        r_value = current_r_bin.to_i(2)
                        g_value = current_g_bin.to_i(2)
                        b_value = current_b_bin.to_i(2)

                        # TODO: change 128 to secret image width
                        # Break loop when secret image height has been met
                        if decoded_pixels[decoded_row_num].length == 221
                            decoded_row_num += 1
                            decoded_pixels.push([])
                        end
                        decoded_pixels[decoded_row_num].push([r_value, g_value, b_value])

                        current_r_bin = ""
                        current_g_bin = ""
                        current_b_bin = ""
                    end
                }
            }
            decoded_pixels.pop() if decoded_pixels[-1].length != 221

            image = MiniMagick::Image.get_image_from_pixels(decoded_pixels, [decoded_pixels[0].length, decoded_pixels.length], 'rgb', 8 ,'png')
            image.write('output1.png')
        end

        def encodeLSBInPixelChannel(channel, y, x, nth_secret_pix)
            value = @secretImgPixels[y][x][@rgb[channel]]
            binary = conver8BitBinary(value)

            nth_cover_pix = nth_secret_pix * 8

            binary.each_char{ |b|
                cover_pix_coordinates = getXYfromNthPixel(nth_cover_pix, @coverImg.width)

                cover_x = cover_pix_coordinates[:x]
                cover_y = cover_pix_coordinates[:y]

                if b == '1'
                    if isEvenNumber(@coverImgPixels[cover_y][cover_x][@rgb[channel]])
                        @coverImgPixels[cover_y][cover_x][@rgb[channel]] += 1
                    end
                elsif b == '0'
                    if !isEvenNumber(@coverImgPixels[cover_y][cover_x][@rgb[channel]])
                        @coverImgPixels[cover_y][cover_x][@rgb[channel]] -= 1
                    end
                end
                
                nth_cover_pix += 1
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

        def getNthPixelFromXY(x, y, width)
            return y*width + x
        end

        def getXYfromNthPixel(n, width)
            pixel_x = n % width
            pixel_y = (n / width).floor

            return {
                x: pixel_x, y: pixel_y
            }
        end
    end
end