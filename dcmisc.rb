module Stegno
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