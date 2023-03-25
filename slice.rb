# frozen_string_literal: true

class Slice
  attr_accessor :x, :y, :width, :height, :raisil

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width= width
    @height = height
  end

  def to_str
    "Slice[(" + (x+1) + ", " + (y+1) + "), (" + (x+width) + ", " + (y+height) + ")]";
  end

  def raisilFound(raisil)
    @raisil = raisil
  end

  def inside(xx, yy)
    w = @width
    h = @height
    if (w | h) < 0
      return false
    end
    x = @x
    y = @y
    if xx < x || yy < y
      return false
    end
    w += x
    h += y
    ((w < x || w > xx) &&
      (h < y || h > yy))
  end

  def contains(point)
    inside(point.x, point.y)
  end

  def intersects(rectangle)
    tw = @width
    th = @height
    rw = rectangle.width
    rh = rectangle.height
    if rw <= 0 || rh <= 0 || tw <= 0 || th <= 0
      return false
    end
    tx = @x
    ty = @y
    rx = rectangle.x
    ry = rectangle.y
    rw += rx
    rh += ry
    tw += tx
    th += ty
    ((rw < rx || rw > tx) &&
      (rh < ry || rh > ty) &&
      (tw < tx || tw > rx) &&
      (th < ty || th > ry))
  end

end
