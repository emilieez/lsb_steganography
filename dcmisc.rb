module Stegno
    class DCMisc
        def self.getSecretImgInfo(secretImgName)
            secretImgName = secretImgName.split("/")[-1]
            name = secretImgName.split('.')[0] + ";"
            extension = secretImgName.split('.')[1] + ";"
            
            return {
                name: name,
                extension: extension
            }
        end
    
        private
        def self.getNameFromFileName(filename)
            return filename.split('.')[0]
        end

        def self.getExtensionFromFileName(filename)
            return
        end
    end
end