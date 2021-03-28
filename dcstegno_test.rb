output_formats = [
    "svg", "tiff", "bmp", "png"
]

blowfish_key = "foobar2048"
caesar_key = 42

puts "Begin Encoding test..."

Dir.foreach('coverImgs') do |coverImg|
    next if coverImg == '.' or coverImg == '..'

    Dir.foreach('secretImgs') do |secretImg|
        next if secretImg == '.' or secretImg == '..'

        output_formats.each { |ext|
            puts "Hiding #{secretImg} in #{coverImg}"
            
            cover = coverImg.gsub(/\./, "_")
            secret = secretImg.gsub(/\./, "_")
            outputName = "#{secret}-#{cover}.#{ext}"

            system("ruby dcstegno.rb -m encode -c coverImgs/#{coverImg} -o #{outputName} --blowfish #{blowfish_key} --caesar #{caesar_key} -s secretImgs/#{secretImg}")
            puts
        } 

    end

end

puts "================================================="
puts 
puts "Begin Decoding test..."
puts 

output_formats.push('jpg')
output_formats.push('webp')

Dir.foreach('outputs') do |outImg|
    next if outImg == '.' or outImg == '..'

     output_formats.each { |ext|
        output = outImg.gsub(/\./, "_")
        decodeOutputName = "DECODED-#{output}.#{ext}"
        puts "Decoding #{outImg}"

        system("ruby dcstegno.rb -m decode -c outputs/#{outImg} -o #{decodeOutputName} --blowfish #{blowfish_key} --caesar -#{caesar_key}")
        puts
    } 
    puts 
    puts
end