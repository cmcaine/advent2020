module day1

get_input() = parse.(Int, split(read("data/day1", String)))

"""
Find a pair of values from `input` that sums to 2020. There will be exactly one such pair.

O(2n)
"""
function part1(input)
    bs = BitSet(input)
    for a in bs
        a == 1010 && continue
        b = 2020 - a
        b in bs && (@debug a, b; return a * b)
    end
    return 1010^2
end


"""
Find three values from `input` that sum to 2020. There will be exactly one such triple.

O(n(n+1)/2 * log n + n log n) == O(n^2 log n)

My input (and possibly all inputs) allow more naive solutions, but in the general case
we have to search the triangular otherwise we can be fooled by inputs like
[505, 672, 673, 675, 1010].
"""
function part2(input)
    input = sort(input)
    n = length(input)
    @inbounds for x in 1:n
        for y in x+1:n
            a = input[x]
            b = input[y]
            c = 2020 - a - b
            rest = view(input, y+1:n)
            idx = searchsortedfirst(rest, c)
            idx <= length(rest) && rest[idx] == c && (@debug a, b, c; return a * b * c)
        end
    end
end


# Bonus

"""
Return `n` integers s.t. exactly one pair and one triple of values sum to 2020.

All vals in 1:2020
"""
function generate_input(n=200)
    vals = Int[]
end

using ReTest

@testset "day1" begin
    @test part1([505, 672, 673, 675, 1010, 1515]) == 505 * 1515
    @test part2([505, 672, 673, 675, 1010]) == 672 * 673 * 675
end

@testset "bench" begin
    @eval using BenchmarkTools
    @eval begin
        input = get_input()
        @info "Day 1"
        @btime part1($input)
        @btime part2($input)
        println()
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = get_input()
    @show part1(input)
    @show part2(input)
end

end
