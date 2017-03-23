class PPMImage
  attr_reader :height, :width

  def initialize(h, w)
    @height = h
    @width = w
    @data = [[0,0,0]] * h * w
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
      file.write("255\n")
      @data.each_with_index do |pixel, idx|
        file.write("#{pixel[0]} #{pixel[1]} #{pixel[2]} ")
      end
    end
  end
end
