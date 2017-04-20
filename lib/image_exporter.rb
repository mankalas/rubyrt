require 'chunky_png'

class ImageExporter
  attr_reader :height, :width

  def initialize(h, w)
    @height = h
    @width = w
    @data = [Color::WHITE] * (h * w - 1)
  end

  def index_at_point(x, y)
    x + (y * width)
  end

  def set(x, y, color)
    @data[index_at_point(x, y)] = color
  end

  def write_ppm(file_name)
    File.open("#{file_name}.ppm", 'w') do |file|
      file.write("P3\n")
      file.write("# test\n")
      file.write("#{width} #{height}\n")
      file.write("255\n")
      @data.each do |pixel|
        pixel = pixel.normalize
        file.write("#{pixel.r} #{pixel.g} #{pixel.b} ")
      end
    end
  end

  def write_png(file_name)
    png = ChunkyPNG::Image.new(height, width, ChunkyPNG::Color::TRANSPARENT)
    @data.each_with_index do |pixel, i|
      pixel = pixel.saturate
      png[i % width, i / width] = ChunkyPNG::Color.rgb(pixel.x, pixel.y, pixel.z)
    end
    png.save("#{file_name}.png", :fast_rgba)
  end
end
