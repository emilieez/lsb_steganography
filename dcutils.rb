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
            secretImgInfo = Stegno::DCMisc.getSecretImgInfo(@secretImgName)

            outputFile = @outputFile.split('.')[0]
            outputFormat = @outputFormat.split('.')[1]

            key = Blowfish::Key.generate(@key)
            encrypted_secretImgName = Blowfish.encrypt(secretImgInfo[:name], key)

            dcImage = Stegno::DCImage.new(@coverImg, @outputFile, @outputFormat, @secretImg, encrypted_secretImgName, secretImgInfo[:extension])
            dcImage.encodeSecretFileInfo()
            dcImage.encodeImage()
        end

        def decode
            dcImage = Stegno::DCImage.new(@coverImg, @outputFile, @outputFormat)
            dcImage.decodeSecretFileInfo()
            dcImage.decodeImage()
        end
    end
end