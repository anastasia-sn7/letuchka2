require_relative 'point'
require_relative 'raisil'
require_relative 'slice'

class Main

  def initialize
    @raisils = Array.new
  end

  def main
    cake = ".o.o....\n........\n....o...\n........\n.....o..\n........"
    cake_dev = cake.split("\n")
    width = cake_dev.length
    length = cake_dev[0].length

    (0...width).each { |i|
      string = cake_dev[i]
      (0...string.length).each { |j|
        if string[j] == 'о' || string[j] == 'o'
          raisil = Raisil.new(j, i)
          @raisils << raisil
        end
      }
    }

    raisilsAmount = @raisils.size

    if raisilsAmount <= 1
      raise ArgumentError.new("Too less raisils. The amount has to be more than 1")
    end

    if raisilsAmount >= 10
      raise ArgumentError.new("Too too much raisils. The amount has to be less than 10")
    end

    slices = calculate_slices(length, width, length * width / raisilsAmount)
    solutions = get_solutions(slices, raisilsAmount)
    solutionsAmount = solutions.size

    solutions.each_with_index do |solution, solution_index|
      solution.each_with_index do |slice, slice_index|
        diapX = slice.x...slice.width+slice.x
        diapY = slice.y...slice.height+slice.y
        @raisils.each do |raisil|
          if(diapX.include?(raisil.x) && diapY.include?(raisil.y))
            slice.raisilFound(raisil)
          end
        end
      end
    end

    puts "Solution's amount: #{solutionsAmount}"

    array = Array.new(solutionsAmount) { Array.new(solutions[0].size, 0) }
    solutions.each_with_index do |solution, solution_index|
      solution.each_with_index do |slice, slice_index|
        array[solution_index][slice_index] = slice.width
      end
    end

    solutions[0].size.times do |slice_index|
      max = 0
      counter = 0
      solutionsAmount.times do |solution_index|
        if array[solution_index][slice_index] > max
          max = array[solution_index][slice_index]
          counter += 1
        elsif array[solution_index][slice_index] == max
          counter += 1
        end
      end

      solutionsAmount.times do |solution_index|
        if array[solution_index][slice_index] < max
          array[solution_index].fill(0)
        end
      end
    end

    finalSolutionIndex = -1
    solutions[0].size.times do |slice_index|
      solutionsAmount.times do |solution_index|
        if array[solution_index][slice_index] != 0
          finalSolutionIndex = solution_index
        end
      end
    end

    puts "__________________________________________"
    puts "|_____________FINAL SOLUTION_____________|"
    puts "|________________________________________|\n"
    if finalSolutionIndex != -1
      puts "Як виглядає пиріг:"
      print_array(solutions[finalSolutionIndex], length, width)
      puts "Як він порізаний:"
      print_slices(solutions[finalSolutionIndex], length, width)
    else
      puts "Однакові розв'язки"
    end
  end

  def is_one_rasil(slice1, slice2)
    first_slice = false
    second_slice = false
    amount_in_first_slice = 0
    amount_in_second_slice = 0
    @raisils.each do |raisil|
      raisil_point = Point.new(raisil.x, raisil.y)
      if slice1.contains(raisil_point) && slice2.contains(raisil_point)
        return false
      end
      if slice1.contains(raisil_point)
        amount_in_first_slice += 1
        if amount_in_first_slice == 1
          first_slice = true
        else
          return false
        end
      end
      if slice2.contains(raisil_point)
        amount_in_second_slice += 1
        if amount_in_second_slice == 1
          second_slice = true
        else
          return false
        end
      end
    end
    first_slice && second_slice
  end

  def does_overlap(slice1, slice2)
    !slice1.intersects(slice2) && is_one_rasil(slice1, slice2)
  end

  def do_slices_overlap(slices)
    (0...slices.size).each { |i|
      (i + 1...slices.size).each { |j|
        if does_overlap(slices[i], slices[j])
          next
        else
          return false
        end
      }
    }
    true
  end

  def calculate_slices(length, width, area)
    result = []
    (0...length).each do |x1|
      (0...width).each do |y1|
        (x1...length).each do |x2|
          (y1...width).each do |y2|
            slice = Slice.new(x1, y1, (x2 - x1 + 1), (y2 - y1 + 1))
            if slice.height * slice.width == area
              result << slice
            end
          end
        end
      end
    end
    result
  end

  def get_solutions(all_available_slices, raisilsAmount)
    solutions = []
    get_all_solutions(all_available_slices, solutions, [], raisilsAmount, 0)
    solutions
  end

  def get_all_solutions(all_available_slices, solutions, current_solution, raisilsAmount, start_index)
    if current_solution.size == raisilsAmount
      if do_slices_overlap(current_solution)
        solutions.append(current_solution.clone)
      end
      return
    end

    (start_index...all_available_slices.size).each { |i|
      current_solution.append(all_available_slices[i])
      get_all_solutions(all_available_slices, solutions, current_solution, raisilsAmount, i + 1)
      current_solution.pop
    }
  end

  def print_array(slices, length, width)
    (0...width).each do |j|
      (0...length).each do |i|
        found = false
        slices.each_with_index do |slice, k|
          if slice.contains(Point.new(i, j))
              if slice.raisil.x == i && slice.raisil.y == j
                print 'o'
              else
                print '.'
              end
            found = true
            break
          end
        end
        print " " unless found
      end
      puts
    end
  end

  def print_slices(slices, length, width)
    (0...width).each do |j|
      (0...length).each do |i|
        found = false
        slices.each_with_index do |slice, k|
          if slice.contains(Point.new(i, j))
            print k+1
            found = true
            break
          end
        end
        print " " unless found
      end
      puts
    end
  end

end

main = Main.new
main.main
