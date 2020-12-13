module day9

function get_input(str::String=read("data/day9", String))
    parse.(Int, split(str, '\n'; keepempty=false))
end


function find_invalid(input, window_size=25)
    for idx in window_size+1:length(input)
        v = input[idx]
        found = false
        buf = @view input[idx-window_size:idx-1]
        for a in buf
            b = v - a
            b in buf && (found = true; break)
        end
        found || return v
    end
end


part1 = find_invalid


"""
    part2

The first invalid number in the sequence is preceded somewhere in the sequence
by a contiguous section of integers that sum to it. Find that sequence and sum
the largest and smallest values in it.
"""
function part2(input, window_size=25)
    target = find_invalid(input, window_size)
    lo = 1
    hi = 2
    acc = sum(input[lo:hi])
    while true
        hi += 1
        acc += input[hi]
        if acc > target
            acc -= input[lo]
            acc -= input[hi]
            lo += 1
            hi -= 1
        elseif acc == target
            return sum(extrema(@view input[lo:hi]))
        end
    end
end



using ReTest

@testset "day9" begin
    @testset "examples" begin
        input = """
                35
                20
                15
                25
                47
                40
                62
                55
                65
                95
                102
                117
                150
                182
                127
                219
                299
                277
                309
                576
                """
        x = get_input(input)
        @test part1(x, 5) == 127
        @test part2(x, 5) == 62
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 9"
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
