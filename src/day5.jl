module day5

function get_input(io::IO=open("data/day5"))
    readlines(io)
end

# For test inputs
function get_input(str::String)
    split(str, '\n'; keepempty=false)
end

# TIL: *2^(10 - i) isn't optimised into a bitshift
seat_id(pass) = sum((x == 'B' || x == 'R') << (10 - i) for (i, x) in enumerate(pass))

part1(passes) = maximum(seat_id, passes)

# Find the seat id, x, s.t. x+1 and x-1 are both in `passes`, where passes is
# otherwise a contiguous range of seat ids.
function part2(passes)
    ids = map(seat_id, passes)
    (hi, lo) = extrema(ids)
    only(setdiff(hi:lo, ids))
end

function part2a(passes)
    ids = map(seat_id, passes) |> sort
    for x in 2:length(ids)-1
        a, b = ids[x-1:x]
        a+1 != b && return a+1
    end
    error()
end


using ReTest

@testset "day5" begin
    @testset "examples" begin
        input = """
                BFFFBBFRRR
                FFFBBBFRRR
                BBFFBBFRLL
                """
        x = get_input(input)
        @test part1(x) == 820
        y = get_input()
        @test part2(y) == 603 == part2a(y)
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 5"
            @btime part1(input)
            @btime part2(input)
            @btime part2a(input)
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
