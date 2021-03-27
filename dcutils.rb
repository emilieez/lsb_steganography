require 'blowfish'

module Stegno
    class DCUtils
        def initialize(coverImg, mode, key, secretImg=nil, secretImgName=nil, outputFile=nil)
            @coverImg = coverImg
            @mode = mode
            @key = key
            @secretImg = secretImg
            @secretImgName = secretImgName
            @outputFile = outputFile
        end

        def start
            if @mode == 'encode'
                encode()
            elsif @mode == 'decode'
                decode()
            end
        end

        def encode
            secretImgInfo = Stegno::DCMisc.getImgInfo(@secretImgName)
            outputImgInfo = Stegno::DCMisc.getImgInfo(@outputFile)

            key = Blowfish::Key.generate(@key)
            encrypted_secretImgName = Blowfish.encrypt(secretImgInfo[:name] + "/", key)

            dcImage = Stegno::DCImage.new(@coverImg, outputImgInfo[:name], outputImgInfo[:extension], @secretImg, encrypted_secretImgName, secretImgInfo[:extension] + "/")
            dcImage.encodeSecretFileInfo()
            dcImage.encodeImage()
        end

        def decode
            outputImgInfo = Stegno::DCMisc.getImgInfo(@outputFile)

            dcImage = Stegno::DCImage.new(@coverImg, outputImgInfo[:name], outputImgInfo[:extension])
            dcImage.decodeSecretFileInfo()
            dcImage.decodeImage()
        end
    end
end