class PPMImage
  attr_reader :height, :width

  def initialize(h, w)
    @height = h
    @width = w
    @data = [Color::WHITE] * h * w
  end

  def index_at_point(x, y)
    x + (y * width)
  end

  def set(x, y, color)
    @data[index_at_point(x, y)] = color
  end

  def write(file_name)
    File.open(file_name, 'w') do |file|
      file.write("P3\n")
      file.write("# test\n")
      file.write("#{width} #{height}\n")
      max_pixel = @data.max_by { |pixel| [pixel.r, pixel.g, pixel.b].max }
      file.write("255\n")
      @data.each do |pixel|
        file.write("#{(pixel.r * 255.0).round} #{(pixel.g * 255.0).round} #{(pixel.b * 255.0).round} ")
      end
    end
  end
end
