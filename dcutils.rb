require 'blowfish'

module Stegno
    class DCUtils
        def initialize(coverImg, mode, blowfishKey, secretImg=nil, secretImgName=nil, outputFile=nil)
            @coverImg = coverImg
            @mode = mode
            @blowfishKey = blowfishKey
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

            blowfishKey = Blowfish::Key.generate(@blowfishKey)
            encrypted_secretImgName = Blowfish.encrypt(secretImgInfo[:name] + "/", blowfishKey)

            dcImage = Stegno::DCImage.new(@coverImg, outputImgInfo[:name], outputImgInfo[:extension], blowfishKey, @secretImg, encrypted_secretImgName, secretImgInfo[:extension] + "/")
            dcImage.encodeSecretFileInfo()
            dcImage.encodeImage()
        end

        def decode
            outputImgInfo = Stegno::DCMisc.getImgInfo(@outputFile)

            dcImage = Stegno::DCImage.new(@coverImg, outputImgInfo[:name], outputImgInfo[:extension], @blowfishKey)
            dcImage.decodeSecretFileInfo()
            dcImage.decodeImage()
        end
    end
end