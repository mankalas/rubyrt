class PPMImage
  attr_reader :height, :width

  def initialize(h, w)
    @height = h
    @width = w
    @data = [Color.new(0,0,0)] * h * w
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
      file.write("#{[max_pixel.r, max_pixel.g, max_pixel.b].max}\n")
      @data.each do |pixel|
        file.write("#{pixel.r} #{pixel.g} #{pixel.b} ")
      end
    end
  end
end
