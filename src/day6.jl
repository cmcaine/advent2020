module day6

function get_input(str=read("data/day6", String))
    map(split, split(str, "\n\n"))
end

part1(groups) = sum(grp -> length(union(grp...)), groups)
part2(groups) = sum(grp -> length(intersect(grp...)), groups)


using ReTest


@testset "day6" begin
    @testset "examples" begin
        x = get_input(
                      """
                      abc

                      a
                      b
                      c

                      ab
                      ac

                      a
                      a
                      a
                      a

                      b
                      """)
        @test part1(x) == 11
        @test part2(x) == 6
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 6"
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
