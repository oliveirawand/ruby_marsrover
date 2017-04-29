require_relative 'Rover'
require_relative 'Plateau'

class Jarvis

  attr_reader :rovers
  attr_accessor :plateau
  attr_accessor :inputFileLines
  attr_reader :outputFileLines
  @validRoverOrientations
  @validRoverInstructions

  def initialize
    @validRoverOrientations = ["N", "S", "W", "E"]
    @validRoverInstructions = ["M", "R", "L"]
  end

  public
  def readInput(path)
    #verify if the file exists
    if File.file?(path)
      @inputFileLines = Array.new

      File.open(path, "r:UTF-8").each do |line|
        if line != nil
          @inputFileLines << line.chomp
        end
      end
    else
      puts "The mencioned input file doesn't exist!\nCome on, you're a ninja. Please, check it out."
      exit
    end

    #validate the imported file
    if !isAValidFileInput?
      printExample()
      exit
    end

  end

  public
  def executeCommands
    if !@inputFileLines || @inputFileLines.length == 0
      puts "No file have been imported."
      return
    end

    @rovers = Array.new
    @outputFileLines = Array.new
    @plateau = Plateau.new(@inputFileLines[0])

    #last rover position inside the rovers array
    lastRoverPosition = nil

    #from the second line to the last
    for i in (1...@inputFileLines.length)

      #if the index is an odd, then it means the line contains the initial rover location
      if i%2 == 1
        roverLocation = @inputFileLines[i].split(' ')
        rover = Rover.new
        rover.x = roverLocation[0].to_i()
        rover.y = roverLocation[1].to_i()
        rover.currentOrientation = roverLocation[2].upcase()

        @rovers << rover

        if lastRoverPosition == nil
          lastRoverPosition = 0
        else
          lastRoverPosition += 1
        end

        #verify if it's the last line of the file
        if i == @inputFileLines.length - 1
          finalPosition = rover.x.to_s() + " "\
          + rover.y.to_s() + " "\
          + rover.currentOrientation

          @outputFileLines << finalPosition
        end

      #otherwise, it's the instructions line
      else
        #separate the instructions inside an array and eliminate the \n at the end
        instructions = @inputFileLines[i].upcase.chomp.split(//)

        for x in (0...instructions.length)
          if instructions[x] == "M"
            if canMoveForward?(@rovers[lastRoverPosition])
              @rovers[lastRoverPosition].move(instructions[x])
            end

          else
            @rovers[lastRoverPosition].move(instructions[x])
          end

        end

        #saves the final position of the rover and adds it to the outputFileLines
        finalPosition = @rovers[lastRoverPosition].x.to_s() + " "\
        + @rovers[lastRoverPosition].y.to_s() + " "\
        + @rovers[lastRoverPosition].currentOrientation
        @outputFileLines << finalPosition

      end
    end
  end

  #write the output file and puts it on the screen
  public
  def writeOutput(path)
     if !@outputFileLines || @outputFileLines.length == 0
       "Nothing to export."
       return
     end

     puts "\nFinal rovers position(s):"
     rover = 0

     outputFile = File.open(path, "w")
     for line in @outputFileLines
       outputFile << line + "\n"
       puts "------Rover " + (rover += 1).to_s() + "------"
       puts line + "\n"
     end
     outputFile.close
   end

   #the method run can be used to make Jarvis execute all at once

  public
  def run(path)
     readInput(path)
     if !@inputFileLines || @inputFileLines.length == 0
       puts "\nNo file has been imported."
     else
       executeCommands
       writeOutput(path[0, path.length - 4] + "_OUTPUT.txt")
     end
   end

   #based on plateau area, determines if a rover can move forward or not

  private
  def canMoveForward?(rover)
    case rover.currentOrientation
    when "N"
      if rover.y < @plateau.maxY
        return true
      end

    when "S"
      if rover.y > 0
        return true
      end

    when "W"
      if rover.x > 0
        return true
      end

    when "E"
      if rover.x < @plateau.maxX
        return true
      end
    end

    return false
  end

  #this method has all the rules for a valid file to be inputted
  private
  def isAValidFileInput?
    if @inputFileLines.length < 2
      return false
    end

    for l in (0...@inputFileLines.length)
      #check if is the first line
      if l == 0
        plateau = @inputFileLines[0].split(' ')

          #check the amount of elements
          if plateau.size != 2
            puts "Invalid line: " + (l + 1).to_s() + " - Invalid plateau size."
            return false
          end

          #check if all elements are numeric
          begin
            Integer(plateau[0])
            Integer(plateau[1])
          rescue
            puts "Invalid line: " + (l + 1).to_s() + " - Plateau coordinates are not numbers."
            return false
          end

          #check if is a rover's initial position line
      elsif l%2 == 1
        initialPosition = @inputFileLines[l].split(" ")

        if initialPosition.length != 3
          puts "Invalid line: " + (l + 1).to_s() + " - The line has more or less"\
           + " than 3 elements that must be separated by blank spaces."
          return false

        elsif !@validRoverOrientations.include? initialPosition[2]
          puts "Invalid line: " + (l + 1).to_s() + " - The rovers orientation is invalid."
          return false

        else
          begin
            Integer(initialPosition[0])
            Integer(initialPosition[1])
          rescue
            puts "Invalid line: " + (l + 1).to_s() + " - The first two elements of the line are not valid numbers!"
            return false
          end
        end

      else
        instructions = @inputFileLines[l].chomp.split(//)
        for i in instructions
          if !@validRoverInstructions.include? i.upcase()
            puts "Invalid line: " + (l + 1).to_s() + " - There must be only valid letters for rover instructions."
            return false
          end
        end
      end
    end
    return true;
  end

  private
  def printExample
    puts "\nInvalid file! Please, use an input with at least two lines following the example below:"
    puts "\n5 5"
    puts "1 2 N"
    puts "MMMLRMRLMRL"
    puts "3 5 S"
    puts "LRRRMRLMRLMMM"
  end

end
