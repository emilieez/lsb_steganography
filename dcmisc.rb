module Stegno
    
    CAESAR_ARRAY = (0..255).to_a
    EOL_SYMBOL = "/"

    class DCMisc

        def self.getImgInfo(imgFilePath)
            imgFile = imgFilePath.split("/")[-1]
            name = imgFile.split('.')[0]
            extension = imgFile.split('.')[1]
            
            return {
                name: name,
                extension: extension
            }
        end

        def self.blowfishEncrypt(message, key)
            blowfishKey = Blowfish::Key.generate(key)
            return Blowfish.encrypt(message, blowfishKey)
        end

        def self.blowfishDecrypt(message, key)
            blowfishKey = Blowfish::Key.generate(key)
            return Blowfish.decrypt(message, blowfishKey)
        end

        def self.getCaesarShiftedInt(num, shift)
            result = num + shift
            result = ((result % 255) - 1) if result > 255
            result = 256 + result if result < 0
            return CAESAR_ARRAY[result]
        end
        
        def self.isEvenNumber(num)
            return num % 2 == 0
        end

        def self.conver8BitBinary(num)
            binary = num.to_s(2)
            if binary.length < 8
                zeros = '0' * (8 - binary.length)
                return zeros + binary
            else
                return binary
            end
        end

        def self.getXYfromNthPixel(n, width)
            pixel_x = n % width
            pixel_y = (n / width).floor

            return {
                x: pixel_x, y: pixel_y
            }
        end
    end
end