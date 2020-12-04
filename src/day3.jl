"""
--- Day 3: Toboggan Trajectory ---

With the toboggan login problems resolved, you set off toward the airport. While travel by toboggan might be easy, it's certainly not safe: there's very minimal steering and the area is covered in trees. You'll need to see which angles will take you near the fewest trees.

Due to the local geology, trees in this area only grow on exact integer coordinates in a grid. You make a map (your puzzle input) of the open squares (.) and trees (#) you can see. For example:

..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#

These aren't the only trees, though; due to something you read about once involving arboreal genetics and biome stability, the same pattern repeats to the right many times:

..##.........##.........##.........##.........##.........##.......  --->
#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
.#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
.#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
.#........#.#........#.#........#.#........#.#........#.#........#
#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
#...##....##...##....##...##....##...##....##...##....##...##....#
.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

You start on the open square (.) in the top-left corner and need to reach the bottom (below the bottom-most row on your map).
"""
module day3

# Simple way of getting a bool matrix from the input
function get_input_simple(io=open("data/day3"))
    mapreduce(l -> map(==('#'), collect(l)), hcat, eachline(io))
end

# But what if we used our big ol'brains?
using Mmap

"""
TobogganRun efficiently constructed from bytes so that you can just mmap the file or whatever
"""
struct TobogganRun <: AbstractMatrix{Bool}
    data::Vector{UInt8}
    width::Int
    height::Int
end

function TobogganRun(data)
    width = findfirst(==(UInt8('\n')), data)
    height = length(data) ÷ width
    TobogganRun(data, width, height)
end

"true iff that location is tree"
Base.getindex(tr::TobogganRun, x, y) = tr.data[(y-1) * tr.width + mod1(x, tr.width-1)] == UInt8('#')
Base.size(tr::TobogganRun) = (tr.width-1, tr.height)

function get_input(io=open("data/day3"))
    TobogganRun(Mmap.mmap(io))
end

# For test inputs
function get_input(str::String)
    TobogganRun(codeunits(str))
end

# Note: using tuples rather than vectors of length 2 is better than 20 times faster!
function near_trees(trees, slope)
    loc = (1, 1)
    near_trees = 0
    while loc[2] <= size(trees, 2)
        near_trees += trees[loc...]
        loc = loc .+ slope
    end
    return near_trees
end

part1(trees) = near_trees(trees, (3, 1))

part2(trees) = prod(near_trees(trees, slope) for slope in ((1, 1), (3, 1), (5, 1), (7, 1), (1, 2)))


using ReTest

@testset "day3" begin
    @testset "examples" begin
        input = """
                ..##.......
                #...#...#..
                .#....#..#.
                ..#.#...#.#
                .#...##..#.
                ..#.##.....
                .#.#.#....#
                .#........#
                #.##...#...
                #...##....#
                .#..#...#.#
                """
        trees = get_input(input)
        @test part1(trees) == 7
        @test part2(trees) == 336
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 3"
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
