require 'blowfish'

module Stegno
    class DCUtils
        def initialize(coverImg, mode, key, secretImg=nil, secretImgName=nil, outputFile=nil, outputFormat)
            @coverImg = coverImg
            @mode = mode
            @key = key
            @secretImg = secretImg
            @secretImgName = secretImgName
            @outputFile = outputFile
            @outputFormat = outputFormat
        end

        def start
            if @mode == 'encode'
                encode()
            elsif @mode == 'decode'
                decode()
            end
        end

        def encode
            if @secretImgName.include? "/"
                @secretImgName = @secretImgName.split("/")[-1] 
            end

            secretImgName = @secretImgName.split('.')[0] + ";"
            secretImgFormat = @secretImgName.split('.')[1] + ";"

            outputFile = @outputFile.split('.')[0]
            outputFormat = @outputFormat.split('.')[1]

            key = Blowfish::Key.generate(@key)
            encrypted_secretImgName = Blowfish.encrypt(secretImgName, key)

            dcImage = Stegno::DCImage.new(@coverImg, @secretImg, encrypted_secretImgName, secretImgFormat, @outputFile, @outputFormat)
            dcImage.encodeSecretFileInfo()
            puts "HA;SDLKJFA;SDJ"
            dcImage.encodeImage()
        end

        def decode
            dcImage = Stegno::DCImage.new(@coverImg)
            dcImage.decodeSecretFileInfo()
            dcImage.decodeImage()
        end
    end
end