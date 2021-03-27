require 'optparse'
require 'fastimage'

require_relative 'dcimage.rb'
require_relative 'dcutils.rb'
require_relative 'dcmisc.rb'

options = {
    mode: nil, 
    coverImg: nil, secretImg: nil, output: nil,
    blowfishKey: nil, caesarKey: nil
}

OptionParser.new do |opts|
    opts.on("-m", "--mode encode", String, "[Required] Encode/Decode") do |mode|
        options[:mode] = mode
    end

    opts.on("-c", "--cover-img cover.bmp", String, "[Required] Cover image. Can be any valid image format") do |coverImg|
        options[:coverImg] = coverImg
    end

    opts.on("-o", "--output filename", String, "[Required] Output image. Can be any lossless image format (e.g no jpg/jpeg") do |output|
        options[:output] = output
    end

    opts.on("--blowfish foobar", String, "[Required] Blowfish Encryption key.") do |blowfishKey|
        options[:blowfishKey] = blowfishKey
    end

    opts.on("--caesar 3", String, "[Required] Caesor Cipher shift.") do |caesarKey|
        options[:caesarKey] = caesarKey
    end

    opts.on("-s", "--secret-img secret.bmp", String, "[Required in ENCODE mode] Secret image to be encoded in cover image. Can be any valid image format") do |secretImg|
    options[:secretImg] = secretImg
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

