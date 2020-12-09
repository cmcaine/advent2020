module day8

function get_input(str::String=read("data/day8", String))
    map(split(str, '\n'; keepempty=false)) do line
        op, val = split(line)
        @assert op in ("nop", "acc", "jmp")
        return Symbol(op), parse(Int, val)
    end
end


function acc_machine_step(prg, acc=0, pc=1, lines_visited=BitSet())
    pc == length(prg)+1 && return (:term, acc)
    pc in lines_visited && return (:loop, acc)
    push!(lines_visited, pc)
    op, val = prg[pc]
    if op == :acc
        acc += val
    end
    pc += op == :jmp ? val : 1
    return (:cont, (prg, acc, pc, lines_visited))
end

"""
    acc_machine(prg, acc, pc, lines_visited) -> (:term, Int) | (:loop, Int)
"""
function acc_machine(prg, acc=0, pc=1, lines_visited=BitSet())
    while true
        a, b = acc_machine_step(prg, acc, pc, lines_visited)
        a != :cont && return (a, b)
        prg, acc, pc, lines_visited = b
    end
end

"""
    part1(prg) -> Int

Return the value of the accumulator just before the program enters an infinite loop.

Because the instruction set as defined so far only ever writes to the
accumulator, any line that is executed twice would be executed infinite times.
"""
function part1(prg)
    state, acc = acc_machine(prg)
    @assert state == :loop
    acc
end

"""
    part2(prg) -> Int

Swapping exactly one jmp for a nop or nop for a jmp causes the program to
terminate. Return the value of the accumulator at that point.
"""
function part2(prg)
    pc = 1
    acc = 0
    lines_visited = BitSet()
    while true
        op, val = prg[pc]
        if op in (:nop, :jmp)
            prg1 = copy(prg)
            prg1[pc] = (op == :nop ? (:jmp) : (:nop), val)
            a, b = acc_machine(prg1, acc, pc, copy(lines_visited))
            a == :term && return b
        end
        a, b = acc_machine_step(prg, acc, pc, lines_visited)
        a != :cont && error("No branch terminated!")
        prg, acc, pc, lines_visited = b
    end
end


using ReTest

@testset "day8" begin
    @testset "examples" begin
        input = """
                nop +0
                acc +1
                jmp +4
                acc +3
                jmp -3
                acc -99
                acc +1
                jmp -4
                acc +6
                """
        x = get_input(input)
        @test part1(x) == 5
        @test part2(x) == 8
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 8"
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
