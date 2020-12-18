"""
Day 14, bitmasks

Start: 10:10 17/12/2020

Task:

Simulate a machine with two instructions, :mask and :mem.

:mask sets a 36 trit trinary mask
:mem takes a decimal number, applies the mask and saves it to a numbered memory location

Part 1: return the sum of all memory locations after program terminates.

The mask is treated as X - leave value alone, 1 - always 1, 0 - always 0. We can turn it into two genuine
bitmasks. We'll & with the zeros mask and | with the ones mask.

Finished part 1: 10:40

Break at 11:02

Start again: 12:15

Finished part 2: 12:29

"""
module day14


function get_input(str=read("data/day14", String))
    tokens = split(str)
    instrs = map(1:3:length(tokens)) do idx
        op, ass, val = tokens[idx:idx+2]
        if startswith(op, "mem")
            dest = match(r"\[(\d+)\]$", op).captures[1]
            dest, val = parse.(Int, (dest, val))
            return :mem, (dest=dest, val=val)
        elseif op == "mask"
            return :mask, val
        else
            error("Unrecognized instruction: $op $ass $val")
        end
    end
end

function part1_machine(instrs)
    mem = Dict{Int, UInt64}()
    one_mask = typemin(UInt64)
    zero_mask = 0x0000000ffffffffff # clamp to 36 bits
    for (op, args) in instrs
        if op == :mask
            mask_str = args
            one_mask = 0
            zero_mask = 0
            for chr in mask_str
                one_mask <<= 1
                zero_mask <<= 1
                if chr == '1'
                    one_mask |= 1
                    zero_mask |= 1
                elseif chr == '0'
                    one_mask |= 0
                    zero_mask |= 0
                elseif chr == 'X'
                    one_mask |= 0
                    zero_mask |= 1
                else
                    error(chr)
                end
            end
        else
            dest, val = args
            mem[dest] = (val & zero_mask) | one_mask
        end
    end
    return mem
end

part1(instrs) = part1_machine(instrs) |> values |> sum |> Int

"""
Part 2

Test how many Xs there are in masks

```
masks = filter( ((op, args),) -> op == :mask, y) .|> last
count.(==('X'), masks) |> maximum
```

9, doable with a naive approach, I think.
"""

function part2_machine(instrs)
    # 100x worse performance D:
    # mem = SparseVector(2^36-1, Int[], UInt64[])
    mem = Dict{Int, Int}()
    one_mask = 0
    zero_mask = 0x0000000ffffffffff # clamp to 36 bits
    floating_bits = Int[]
    for (op, args) in instrs
        if op == :mask
            mask_str = args
            one_mask = 0
            empty!(floating_bits)
            for (i, chr) in enumerate(mask_str)
                one_mask <<= 1
                if chr == '1'
                    one_mask |= 1
                elseif chr == '0'
                    one_mask |= 0
                elseif chr == 'X'
                    one_mask |= 0
                    push!(floating_bits, 36-i)
                else
                    error(chr)
                end
            end
        else
            dest, val = args
            dest = (dest & zero_mask) | one_mask
            set_float_index!(mem, dest, val, floating_bits, 1)
        end
    end
    return mem
end

function set_float_index!(mem, dest, val, floating_bits, bit_idx)
    if bit_idx > lastindex(floating_bits)
        mem[dest] = val
    else
        mask = 1 << floating_bits[bit_idx]
        set_float_index!(mem, dest & ~mask, val, floating_bits, bit_idx + 1)
        set_float_index!(mem, dest |  mask, val, floating_bits, bit_idx + 1)
    end
end

part2(instrs) = part2_machine(instrs) |> values |> sum |> Int


## Jakob Nissen's bithacking approach
function part2a_machine(instrs)
    mem = Dict{Int, Int}()
    one_mask = 0
    zero_mask = 0x0000000ffffffffff # clamp to 36 bits
    float_mask = 0
    for (op, args) in instrs
        if op == :mask
            mask_str = args
            one_mask = 0
            float_mask = 0
            for (i, chr) in enumerate(mask_str)
                one_mask <<= 1
                float_mask <<= 1
                if chr == '1'
                    one_mask |= 1
                elseif chr == '0'
                    one_mask |= 0
                elseif chr == 'X'
                    one_mask |= 0
                    float_mask |= 1
                else
                    error(chr)
                end
            end
        else
            dest, val = args
            dest = (dest & zero_mask) | one_mask
            fm = float_mask
            st = fm
            while true
                inv_st = fm & ~st
                mem[(dest & ~fm) | st] = val
                st == 0 && break
                st = (st - 1) & fm
            end
        end
    end
    return mem
end

part2a(instrs) = part2a_machine(instrs) |> values |> sum |> Int

using ReTest

@testset "day14" begin
    @testset "examples" begin
        input = """
                mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
                mem[8] = 11
                mem[7] = 101
                mem[8] = 0
                """
        x = get_input(input)
        @test part1(x) == 165
        y = get_input("""
                      mask = 000000000000000000000000000000X1001X
                      mem[42] = 100
                      mask = 00000000000000000000000000000000X0XX
                      mem[26] = 1
                      """)
        @test part2(y) == 208
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 14"
            @btime part1(input)
            @btime part2(input)
            println()
        end
    end
end

end
