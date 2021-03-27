require 'optparse'
require 'fastimage'

require_relative 'dcimage.rb'
require_relative 'dcutils.rb'
require_relative 'dcmisc.rb'

options = {
    mode: nil,
    coverImg: nil,
    secretImg: nil,
    output: nil,
    outputFormat: nil,
    blowfishKey: nil
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

    opts.on("-o", "--output filename", String, "Output image. Can be any lossless image format (e.g no jpg/jpeg") do |output|
        options[:output] = output
    end

    opts.on("--blowfish foobar", String, "Encryption blowfishKey. Use either ONLY numbers or ONLY text") do |blowfishKey|
        options[:blowfishKey] = blowfishKey
    end

end.parse!



def checkImageSize(cover, secret, secretFileName) 
    coverImgSize = cover.width * (cover.height - 2)

    secretImgSize = secret.width * secret.height

    if coverImgSize < secretImgSize*8 || cover.size < secret.size*8 || cover.width < secretFileName.length * 8
        puts "Cover image is not big enough!"
        exit(1)
    end
end



begin
    coverImg = MiniMagick::Image.open(options[:coverImg])
    secretImg = nil;

    if options[:mode] == "encode"
        secretImg = MiniMagick::Image.open(options[:secretImg])
        checkImageSize(coverImg, secretImg, options[:secretImg])
    end
    stegno_applicaton = Stegno::DCUtils.new(coverImg, options[:mode], options[:blowfishKey], secretImg, options[:secretImg], options[:output])
    stegno_applicaton.start
end

