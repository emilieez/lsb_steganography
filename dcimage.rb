require 'mini_magick'

module Stegno
    class DCImage

        def initialize(coverImg, outputFile, outputFormat, blowfishKey, caesarKey, secretImg=nil, secretImgName=nil, secretImgFormat=nil)
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

            @blowfishKey = blowfishKey
            @caesarKey = caesarKey

            @decodedFilename = ""
            @decodedFileFormat = ""
            @decodedFileDimension = ""
        end

        def encodeSecretFileInfo
            secretFileNameBinary = @secretImgName.unpack("B*")[0]
            secretFileFormatBinary = @secretImgFormat.unpack("B*")[0]
            secretFileDimensionBinary = "#{@secretImg.width.to_s()},#{@secretImg.height.to_s()}#{Stegno::EOL_SYMBOL}".unpack("B*")[0]

            encodeSecretBinary(secretFileNameBinary, 'r')
            encodeSecretBinary(secretFileFormatBinary, 'g')
            encodeSecretBinary(secretFileDimensionBinary, 'b')

            puts "Encrypted secret filename to \"#{@secretImgName}\""
        end

        def encodeSecretBinary(bin, channel)
            cover_x = 0
            bin.each_char{ |b|
                flipLSBInCoverImg(b, 0, cover_x, channel)
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
            image.write("outputs/#{@outputFile}.#{@outputFormat}")
            puts "Encoded cover image to outputs/#{@outputFile}.#{@outputFormat}"

        end

        def encodeLSBInPixelChannel(channel, y, x, nth_secret_pix)
            value = @secretImgPixels[y][x][@rgb[channel]]
            ciphered_value = Stegno::DCMisc.getCaesarShiftedInt(value, @caesarKey)
            binary = Stegno::DCMisc.conver8BitBinary(ciphered_value)

            nth_cover_pix = nth_secret_pix * 8

            binary.each_char{ |b|
                cover_pix_coordinates = Stegno::DCMisc.getXYfromNthPixel(nth_cover_pix, @coverImg.width)

                cover_x = cover_pix_coordinates[:x]
                cover_y = cover_pix_coordinates[:y] + 1

                flipLSBInCoverImg(b, cover_y, cover_x, channel)
                
                nth_cover_pix += 1
            }
        end

        def decodeSecretFileInfo

            filenameDone = false
            formatDone = false
            dimensionDone = false

            rgb_bins = { r: "", g: "", b: "" }


            (0..@coverImg.width - 1).each{ |x|
                rgb_bins[:r] += decodeLSBInPixelChannel('r', 0, x)
                rgb_bins[:g] += decodeLSBInPixelChannel('g', 0, x)
                rgb_bins[:b] += decodeLSBInPixelChannel('b', 0, x)

                if  rgb_bins[:r].length &&  rgb_bins[:b].length && rgb_bins[:g].length == 8
                    r_value = rgb_bins[:r].to_i(2)
                    g_value = rgb_bins[:g].to_i(2)
                    b_value =  rgb_bins[:b].to_i(2)
                    
                    # puts Stegno::DCMisc.blowfishDecrypt(r_value.chr, @blowfishKey)
                    if r_value.chr == Stegno::EOL_SYMBOL && !filenameDone
                        filenameDone = true
                    elsif !filenameDone
                        @decodedFilename += r_value.chr
                    end

                    if g_value.chr == Stegno::EOL_SYMBOL && !formatDone
                        formatDone = true
                    elsif !formatDone
                        @decodedFileFormat += g_value.chr
                    end

                    if b_value.chr == Stegno::EOL_SYMBOL && !dimensionDone
                        dimensionDone = true
                    elsif !dimensionDone
                        @decodedFileDimension += b_value.chr
                    end

                    if filenameDone && formatDone && dimensionDone
                        break
                    end

                    rgb_bins = { r: "", g: "", b: "" }
                end
            }

            decrypted_secretImgName = Stegno::DCMisc.blowfishDecrypt(@decodedFilename, @blowfishKey)
            puts "Found secret image: #{decrypted_secretImgName}.#{@decodedFileFormat}"
        end

        def decodeImage
            max_coverImg_y = @coverImg.height
            max_coverImg_x = @coverImg.width
            
            decoded_pixels = [[]]

            rgb_bins = { r: "", g: "", b: "" }

            decoded_y_idx = 0

            secretImg_width = @decodedFileDimension.split(",")[0].to_i
            secretImg_height = @decodedFileDimension.split(",")[1].to_i

            (1..max_coverImg_y - 1).each{ |y|
                (0..max_coverImg_x - 1).each{ |x|
                    rgb_bins[:r] += decodeLSBInPixelChannel('r', y, x)
                    rgb_bins[:g] += decodeLSBInPixelChannel('g', y, x)
                    rgb_bins[:b] += decodeLSBInPixelChannel('b', y, x)

                    if rgb_bins[:r].length && rgb_bins[:g].length && rgb_bins[:b].length == 8

                        r_value = Stegno::DCMisc.getCaesarShiftedInt(rgb_bins[:r].to_i(2), @caesarKey)
                        g_value = Stegno::DCMisc.getCaesarShiftedInt(rgb_bins[:g].to_i(2), @caesarKey)
                        b_value = Stegno::DCMisc.getCaesarShiftedInt(rgb_bins[:b].to_i(2), @caesarKey)

                        if decoded_pixels[decoded_y_idx].length == secretImg_width
                            decoded_y_idx += 1
                            decoded_pixels.push([])
                        end
                        decoded_pixels[decoded_y_idx].push([r_value, g_value, b_value])
                        rgb_bins = { r: "", g: "", b: "" }
                    end
                }
            }

            # Trim extra pixels to match the secret image width and height
            decoded_pixels.pop() if decoded_pixels[-1].length != secretImg_width
            decoded_pixels = decoded_pixels[0..secretImg_height.to_i - 1]

            image = MiniMagick::Image.get_image_from_pixels(decoded_pixels, [decoded_pixels[0].length, decoded_pixels.length], 'rgb', 8, @outputFormat)
            
            image.write("outputs/#{@outputFile}.#{@outputFormat}")
            puts "Outputted secret image to outputs/#{@outputFile}.#{@outputFormat}"
        end

        def flipLSBInCoverImg(b, cover_y, cover_x, channel)
            if b == '1'
                if Stegno::DCMisc.isEvenNumber(@coverImgPixels[cover_y][cover_x][@rgb[channel]])
                    @coverImgPixels[cover_y][cover_x][@rgb[channel]] += 1
                end
            elsif b == '0'
                if !Stegno::DCMisc.isEvenNumber(@coverImgPixels[cover_y][cover_x][@rgb[channel]])
                    @coverImgPixels[cover_y][cover_x][@rgb[channel]] -= 1
                end
            end
        end

        def decodeLSBInPixelChannel(channel, y, x)
            value = @coverImgPixels[y][x][@rgb[channel]]
            binary = Stegno::DCMisc.conver8BitBinary(value)
            return binary[7]
        end
        
    end
end