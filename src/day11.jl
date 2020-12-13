module day11

# Using an enum for fun
@enum CellType::UInt8 floor empty_seat occupied_seat

# String -> Matrix{CellType}
get_input(str=read("data/day11", String)) = mapreduce(hcat, split(str)) do line
    map(c -> c == 'L' ? empty_seat : floor, collect(line))
end

# Make our Matrices easier to read
# Open question: why did I need to define both of these?
function Base.show(io::IO, ::MIME"text/plain", x::CellType)
    x = min(UInt8(x), 3)
    chars = ('.', 'L', '#')
    x > 2 ? print(io, "#undef") : print(io, chars[x+1])
end
function Base.show(io::IO, x::CellType)
    x = min(UInt8(x), 3)
    chars = ('.', 'L', '#')
    x > 2 ? print(io, "#undef") : print(io, chars[x+1])
end

# f(x, idx) -> indices of the surrounding cells
# f(x, (1, 1)) -> (idx2 for idx2 in CartesianIndex(1, 1):CartesianIndex(2, 2) if idx2 != idx)
# f(x, (2, 2)) -> (idx2 for idx2 in CartesianIndex(1, 1):CartesianIndex(3, 3) if idx2 != idx)
function neighbours(A, idx)
    x = idx[1]
    y = idx[2]
    tl = CartesianIndex(max(1, x - 1), max(1, y - 1))
    br = CartesianIndex(min(size(A, 1), x + 1), min(size(A, 2), y + 1))
    return [idx2 for idx2 in tl:br if idx2 != idx]
end

"""
    If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
    If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
    Otherwise, the seat's state does not change.
"""
function automata_step(A)
    map(CartesianIndex(1, 1):CartesianIndex(size(A)...)) do idx
        v = A[idx]
        v == floor && return v
        num_occupied = count(==(occupied_seat), @view A[neighbours(A, idx)])
        if v == empty_seat && num_occupied == 0
            return occupied_seat
        elseif v == occupied_seat && num_occupied >= 4
            return empty_seat
        else
            return v
        end
    end
end

function part1(A)
    local A′
    while true
        A′ = automata_step(A)
        if all(A′ .== A)
            break
        end
        A = A′
    end
    return count(==(occupied_seat), A)
end


### Part 2

# Is the first seat visible in this direction occupied?
function visible_neighbours(A, idx, dir)
    to_check = idx
    while true
        to_check = to_check + dir
        checkbounds(Bool, A, to_check) || return false
        A[to_check] == floor && continue
        return A[to_check] == occupied_seat
    end
end


function automata_step2(A)
    dirs = tuple((x for x in CartesianIndex(-1, -1):CartesianIndex(1, 1) if x != zero(x))...)
    map(CartesianIndex(1, 1):CartesianIndex(size(A)...)) do idx
        v = A[idx]
        v == floor && return v
        num_occupied = count(visible_neighbours(A, idx, dir) for dir in dirs)
        if v == empty_seat && num_occupied == 0
            return occupied_seat
        elseif v == occupied_seat && num_occupied >= 5
            return empty_seat
        else
            return v
        end
    end
end

function part2(A)
    local A′
    while true
        A′ = automata_step2(A)
        if all(A′ .== A)
            break
        end
        A = A′
    end
    return count(==(occupied_seat), A)
end

# But what if we avoided allocating a new matrix each time and just swapped between two buffers?
# Answer: ~80x faster :)
function automata_step2!(A′, A)
    dirs = tuple((x for x in CartesianIndex(-1, -1):CartesianIndex(1, 1) if x != zero(x))...)
    foreach(CartesianIndex(1, 1):CartesianIndex(size(A)...)) do idx
        v = A[idx]
        v == floor && return A′[idx] = v
        num_occupied = count(visible_neighbours(A, idx, dir) for dir in dirs)
        if v == empty_seat && num_occupied == 0
            return A′[idx] = occupied_seat
        elseif v == occupied_seat && num_occupied >= 5
            return A′[idx] = empty_seat
        else
            return A′[idx] = v
        end
    end
    return A′
end

function part2a(A)
    A′ = similar(A)
    while true
        A′ = automata_step2!(A′, A)
        if all(A′ .== A)
            break
        end
        # Swap buffers
        A, A′ = A′, A
    end
    return count(==(occupied_seat), A)
end


using ReTest

@testset "day11" begin
    @testset "examples" begin
        input = """
                L.LL.LL.LL
                LLLLLLL.LL
                L.L.L..L..
                LLLL.LL.LL
                L.LL.LL.LL
                L.LLLLL.LL
                ..L.L.....
                LLLLLLLLLL
                L.LLLLLL.L
                L.LLLLL.LL
                """
        A = get_input(input)
        @test part1(A) == 37
        @test part2(A) == 26
        @test part2a(A) == 26
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 11"
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
