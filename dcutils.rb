module Stegno
    class DCUtils
        def initialize(coverImg, secretImg, mode)
            @coverImg = coverImg
            @secretImg = secretImg
            @mode = mode
        end

        def start
            if @mode == 'encode'
                encode()
            elsif @mode == 'decode'
                decode()
            end
        end

        def encode
            puts "here"
        end

        def decode(pixel)
        end
    end
end