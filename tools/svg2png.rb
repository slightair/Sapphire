require 'rexml/document'

svg_images = Dir.glob('images/*.svg')

svg_images.each_with_index do |src, index|
  base = File.basename(src, ".svg")
  changed_color_src = "out/svg/#{base}.svg"
  dest = "out/png/#{base}.png"

  svg = REXML::Document.new(File.new(src))

  svg.get_elements("//path|//circle|//polygon|//ellipse").each do |path|
    path.add_attribute("fill", "#6474a7")
  end

  open(changed_color_src, "w") do |f|
    svg.write(f)
  end

  cmd = "convert -resize 480x480 -mattecolor '#ffffff' -frame 16x16 #{changed_color_src} #{dest}"
  `#{cmd}`

  puts "#{index + 1}/#{svg_images.size}"
end
