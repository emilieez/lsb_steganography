require 'optparse'
require 'fastimage'

require_relative 'dcimage.rb'
require_relative 'dcutils.rb'

options = {
    mode: nil,
    coverImg: nil,
    secretImg: nil,
    output: nil
}

OptionParser.new do |opts|
    opts.on("-m", "--mode encode", String, "Encode/Decode") do |mode|
        options[:mode] = mode
    end

    opts.on("-c", "--cover-img cover.bmp", String, "Image to be used as cover. Can be any valid image format") do |coverImg|
        options[:coverImg] = coverImg
    end

    opts.on("-s", "--secret-img secret.bmp", String, "Secret image to be encoded in cover image. Can be any valid image format") do |secretImg|
        options[:secretImg] = secretImg
    end

    opts.on("-o", "--output output.bmp", String, "Output image. Can be any valid image format") do |output|
        options[:output] = output
    end

end.parse!



def checkImageSize(cover, secret) 
    coverImgSize = FastImage.size(cover)
    secretImgSize = FastImage.size(secret)

    if coverImgSize[0] * coverImgSize[1] < (secretImgSize[0] * secretImgSize[1] * 8)
        puts "Cover image is not big enough!"
        # exit(1)
    end
end



begin
    checkImageSize(options[:coverImg], options[:secretImg])

    coverImg = MiniMagick::Image.open(options[:coverImg])
    secretImg = MiniMagick::Image.open(options[:secretImg])
    
    stegno_applicaton = Stegno::DCUtils.new(coverImg, secretImg, "testImage", options[:mode])
    stegno_applicaton.start
end

