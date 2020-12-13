module day12

function get_input(str=read("data/day12", String))
    map(split(str)) do line
        (op, val...) = line
        val = parse(Int, val)
        op, val
    end
end

# Notes on the input:
#
# All L, R rotations are 90, 180 or 270.
# @assert !any( ((op, val),) -> (op in "LR") && !(val in (90, 180, 270)), y )


# instr[] -> Int
function part1(instrs)
    loc = (0, 0)
    dirs = ((0, 1),
            (1, 0),
            (0, -1),
            (-1, 0))
    N, E, S, W = dirs
    heading = 2
    for (op, val) in instrs
        # Find the new location and heading after executing the instruction
        if     op == 'N'        loc = loc .+ N .* val
        elseif op == 'E'        loc = loc .+ E .* val
        elseif op == 'S'        loc = loc .+ S .* val
        elseif op == 'W'        loc = loc .+ W .* val
        elseif op == 'F'        loc = loc .+ dirs[heading] .* val
        elseif op == 'L'        # Avoiding mod like this is a little faster
            heading -= val ÷ 90
            heading < 1 && (heading = heading + 4)
        elseif op == 'R'
            heading += val ÷ 90
            heading > 4 && (heading = heading - 4)
        else
            error("Unrecognised: $((op, val))")
        end
    end
    sum(abs, loc)
end


# Part 2!
# Open questions: This has one allocation of 16 bytes in it, but I don't know where it is.
function part2(instrs)
    loc = (0, 0)
    N, E, S, W = ((0, 1), (1, 0), (0, -1), (-1, 0))
    waypoint = (10, 1)
    # Rotate the waypoint?
    #
    # We could use a rotation matrix:
    #
    # R = [cos(θ) -sin(θ);
    #      sin(θ)  cos(θ)]
    #
    # But for θ that is a multiple of ½π, these come out as simple swaps,
    # and it's much more efficient to do these than to do floating point
    # arithmetic!
    #
    # rotate(1, x, y) = (y, -x)
    # rotate(2, x, y) = (-x, -y)
    # rotate(3, x, y) = (-y, x)
    "Rotate vec 90° clockwise about the origin some number of times (times ∈ 1:3)"
    function rotate90(times, (x, y))
        if times == 1
            (y, -x)
        elseif times == 2
            (-x, -y)
        elseif times == 3
            (-y, x)
        else
            throw(DomainError(times, "times ∉ 1:3"))
        end
    end
    for (op, val) in instrs
        if     op == 'N'        waypoint = waypoint .+ N .* val
        elseif op == 'E'        waypoint = waypoint .+ E .* val
        elseif op == 'S'        waypoint = waypoint .+ S .* val
        elseif op == 'W'        waypoint = waypoint .+ W .* val
        elseif op == 'F'        loc = loc .+ waypoint .* val
        elseif op == 'L'        waypoint = rotate90(4 - (val ÷ 90), waypoint)
        elseif op == 'R'        waypoint = rotate90(val ÷ 90, waypoint)
        else                    error("Unrecognised: $((op, val))")
        end
    end
    sum(abs, loc)
end


# Notes from other people's solutions:
#
# You can use a complex number (I knew this) and represent the rotations by 90° as
# `loc * (-im)^(val ÷ 90)` (I did not know this!).
#
# Dheepak had an especially nice solution:

function part1_dheepak(data)
    current = 0 + 0im
    direction = 1 + 0im
    for (action, move) in data
        if     action == 'N'  current += move * im
        elseif action == 'S'  current -= move * im
        elseif action == 'E'  current += move
        elseif action == 'W'  current -= move
        elseif action == 'F'  current += direction * move
        elseif action == 'L'  direction *= im^(move ÷ 90)
        elseif action == 'R'  direction *= (-im)^(move ÷ 90)
        else                  error("Invalid action: $action")
        end
    end
    abs(current.re) + abs(current.im)
end

# Their original version used `&&` and was 8 times slower
# Changing the &&s to if/elseif speeds it up a lot, like this it is only ~30% slower
# It's very pretty and only took them 20 minutes to write, so this is a clear win over mine ;)


using ReTest

@testset "day12" begin
    @testset "examples" begin
        x = get_input("""
                      F10
                      N3
                      F7
                      R90
                      F11
                      """)
        @test part1(x) == 25

        z = get_input("""
                      F10
                      N3
                      F7
                      R180
                      F11
                      """)
        @test part1(z) == 9

        # Given in problem
        @test part2(x) == 286

        # part 2 interpretation of z
        # F10: + (100, 10)
        # N3: wp = (10, 4)
        # F7: +  (70,  28)
        # R180: wp = (-10, -4)
        # F11: + (-110, -44)
        #
        # loc: 60, -6
        # dist = 66
        @test part2(z) == 66

        a = get_input("""
                      F10
                      N3
                      F7
                      L90
                      F11
                      """)
        # part 2 interpretation of a
        # F10: + (100, 10)
        # N3: wp = (10, 4)
        # F7: +  (70,  28)
        # L90: wp = (-4, 10)
        # F11: + (-44, 110)
        #
        # loc: 126, 148
        # dist = 274
        @test part2(a) == 274
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 12"
            @btime part1(input)
            @btime part2(input)
            println()
        end
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    input = get_input()
    @show part1(input)
    @show part2(input)
end

end
