require 'mini_magick'

module Stegno
    class DCImage

        def initialize(coverImg, outputFile, outputFormat, secretImg=nil, secretImgName=nil, secretImgFormat=nil)
            @coverImg = coverImg
            @secretImg = secretImg

            @secretImgName = secretImgName
            @secretImgFormat = secretImgFormat

            @outputFile = outputFile
            @outputFormat = outputFormat

            @secretImgPixels = @secretImg.get_pixels if @secretImg
            @coverImgPixels = @coverImg.get_pixels

            @rgb = {
                "r"=>0, "g"=>1, "b"=> 2
            }

            @decodedFilename = ""
            @decodedFileFormat = ""
            @decodedFileWidth = ""
        end

        def encodeSecretFileInfo
            secretFileNameBinary = @secretImgName.unpack("B*")[0]
            secretFileFormatBinary = @secretImgFormat.unpack("B*")[0]

            secretFileWidthBinary = "#{@secretImg.width.to_s()};".unpack("B*")[0]

            cover_x = 0
            secretFileNameBinary.each_char{ |b|
                flipLSBInCoverImg(b, 0, cover_x, 'r')
                cover_x += 1
            }

            cover_x = 0
            secretFileFormatBinary.each_char{ |b|
                flipLSBInCoverImg(b, 0, cover_x, 'g')
                cover_x += 1
            }

            cover_x = 0
            secretFileWidthBinary.each_char{ |b|
                flipLSBInCoverImg(b, 0, cover_x, 'b')
                cover_x += 1
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

            image = MiniMagick::Image.get_image_from_pixels(@coverImgPixels, [@coverImg.width, @coverImg.height], 'rgb', 8 , @outputFormat)
            image.write("#{@outputFile}.#{@outputFormat}")
            puts "Encoded cover image > #{@outputFile}.#{@outputFormat}"

        end

        def decodeSecretFileInfo

            filenameDone = false
            formatDone = false
            widthDone = false
            
            current_r_bin = ""
            current_g_bin = ""
            current_b_bin = ""


            (0..@coverImg.width - 1).each{ |x|
                current_r_bin += decodeLSBInPixelChannel('r', 0, x)
                current_g_bin += decodeLSBInPixelChannel('g', 0, x)
                current_b_bin += decodeLSBInPixelChannel('b', 0, x)

                if current_r_bin.length && current_b_bin.length && current_g_bin.length == 8
                    r_value = current_r_bin.to_i(2)
                    g_value = current_g_bin.to_i(2)
                    b_value = current_b_bin.to_i(2)
                    
                    if r_value.chr == ";" && !filenameDone
                        filenameDone = true
                    else
                        @decodedFilename += r_value.chr
                    end

                    if g_value.chr == ";" && !formatDone
                        formatDone = true
                    else
                        @decodedFileFormat += g_value.chr
                    end

                    if b_value.chr == ";" && !widthDone
                        widthDone = true
                    else
                        @decodedFileWidth += b_value.chr
                    end

                    if filenameDone && formatDone && widthDone
                        Break
                    end

                    current_r_bin = ""
                    current_g_bin = ""
                    current_b_bin = ""
                end
            }
        end

        def decodeImage
            max_coverImg_y = @coverImg.height
            max_coverImg_x = @coverImg.width
            
            decoded_pixels = [[]]

            current_r_bin = ""
            current_g_bin = ""
            current_b_bin = ""

            decoded_row_num = 0

            (1..max_coverImg_y - 1).each{ |y|
                (0..max_coverImg_x - 1).each{ |x|
                    current_r_bin += decodeLSBInPixelChannel('r', y, x)
                    current_g_bin += decodeLSBInPixelChannel('g', y, x)
                    current_b_bin += decodeLSBInPixelChannel('b', y, x)

                    if current_r_bin.length && current_b_bin.length && current_g_bin.length == 8
                        r_value = current_r_bin.to_i(2)
                        g_value = current_g_bin.to_i(2)
                        b_value = current_b_bin.to_i(2)

                        if decoded_pixels[decoded_row_num].length == @decodedFileWidth.to_i
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
            decoded_pixels.pop() if decoded_pixels[-1].length != @decodedFileWidth.to_i

            image = MiniMagick::Image.get_image_from_pixels(decoded_pixels, [decoded_pixels[0].length, decoded_pixels.length], 'rgb', 8, @outputFormat)
            
            puts "Decoded image > #{@outputFile}.#{@outputFormat}"
            image.write("#{@outputFile}.#{@outputFormat}")
        end

        def encodeLSBInPixelChannel(channel, y, x, nth_secret_pix)
            value = @secretImgPixels[y][x][@rgb[channel]]
            binary = conver8BitBinary(value)

            nth_cover_pix = nth_secret_pix * 8

            binary.each_char{ |b|
                cover_pix_coordinates = getXYfromNthPixel(nth_cover_pix, @coverImg.width)

                cover_x = cover_pix_coordinates[:x]
                cover_y = cover_pix_coordinates[:y] + 1

                flipLSBInCoverImg(b, cover_y, cover_x, channel)
                
                nth_cover_pix += 1
            }
        end

        def flipLSBInCoverImg(b, cover_y, cover_x, channel)
            if b == '1'
                if isEvenNumber(@coverImgPixels[cover_y][cover_x][@rgb[channel]])
                    @coverImgPixels[cover_y][cover_x][@rgb[channel]] += 1
                end
            elsif b == '0'
                if !isEvenNumber(@coverImgPixels[cover_y][cover_x][@rgb[channel]])
                    @coverImgPixels[cover_y][cover_x][@rgb[channel]] -= 1
                end
            end
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

        def getXYfromNthPixel(n, width)
            pixel_x = n % width
            pixel_y = (n / width).floor

            return {
                x: pixel_x, y: pixel_y
            }
        end
    end
end