class AbstractObject
  attr_reader :center

  def initialize(center)
    @center = center
  end
end

class Sphere < AbstractObject
  attr_reader :radius, :color

  def initialize(center, radius, color)
    super(center)
    @radius = radius
    @color = color
  end

  def distance_to_intersection_with(ray)
    radical = ray.direction.dot(ray.origin - center)**2 -
              (ray.origin - center).norm**2 +
              radius**2
    return nil if radical < -EPS

    distance = -ray.direction.dot(ray.origin - center)
    return distance if radical.abs < EPS
    distance - Math.sqrt(radical)
  end
end
