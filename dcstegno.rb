require 'optparse'

options = {}

OptionParser.new do |opts|
    opts.on("-e", "--encode", String, "Encode mode") do |encode|
        options[:encode] = true
    end

    opts.on("-d", "--decode", String, "Decode mode") do |decode|
        options[:decode] = true
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