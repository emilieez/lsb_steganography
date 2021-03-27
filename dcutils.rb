require 'blowfish'

module Stegno
    class DCUtils
        def initialize(coverImg, mode, blowfishKey, caesarKey, secretImg=nil, secretImgName=nil, outputFile=nil)
            @mode = mode
            @coverImg = coverImg
            @secretImg = secretImg
            @secretImgName = secretImgName
            @outputFile = outputFile
            
            @blowfishKey = blowfishKey
            @caesarKey = caesarKey
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
            encrypted_secretImgName = Stegno::DCMisc.blowfishEncrypt(secretImgInfo[:name] + "/", @blowfishKey)

            dcImage = Stegno::DCImage.new(@coverImg, outputImgInfo[:name], outputImgInfo[:extension], blowfishKey, @caesarKey, @secretImg, encrypted_secretImgName, secretImgInfo[:extension] + "/")
            dcImage.encodeSecretFileInfo()
            dcImage.encodeImage()
        end

        def decode
            outputImgInfo = Stegno::DCMisc.getImgInfo(@outputFile)

            dcImage = Stegno::DCImage.new(@coverImg, outputImgInfo[:name], outputImgInfo[:extension], @blowfishKey, @caesarKey)
            dcImage.decodeSecretFileInfo()
            dcImage.decodeImage()
        end
    end
end