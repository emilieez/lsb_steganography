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
    end
end