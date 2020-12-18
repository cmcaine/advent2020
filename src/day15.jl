"""
Day 15, rambunctious recitation

Store the last turn number for each number seen (a Dict will be fine, I guess)

"""
module day15

function game(initial, N)
    turn_seen = Dict(v => idx for (idx, v) in enumerate(initial))
    last_value = last(initial)
    for current_turn in length(initial)+1:N
        seen = get(turn_seen, last_value, nothing)
        turn_seen[last_value] = current_turn - 1
        if isnothing(seen)
            last_value = 0
        else
            last_value = current_turn - 1 - seen
        end
    end
    return last_value
end

# Faster and with fewer allocations than game_vector for large N
function game_mixed(initial, N, vecsize=N÷2)
    # Use a vector for values 0:vecsize-1
    # And a dict for bigger values.
    vector = zeros(Int32, vecsize)
    dict = Dict{Int, Int}()
    get(x) = x < vecsize ? vector[x+1] : Base.get(dict, x, 0)
    set(x, val) = x < vecsize ? (vector[x+1]=val) : (dict[x]=val)

    for (idx, v) in enumerate(initial)
        set(v, idx)
    end

    last_value = last(initial)
    for current_turn in length(initial)+1:N
        seen = get(last_value)
        set(last_value, current_turn-1)
        if seen == 0
            last_value = 0
        else
            last_value = current_turn - 1 - seen
        end
    end
    return last_value
end

function game_vector(initial, N)
    vector = zeros(Int32, N+1)
    get(x) = vector[x+1]
    set(x, val) = (vector[x+1]=val)

    for (idx, v) in enumerate(initial)
        set(v, idx)
    end

    last_value = last(initial)
    for current_turn in length(initial)+1:N
        seen = get(last_value)
        set(last_value, current_turn-1)
        if seen == 0
            last_value = 0
        else
            last_value = current_turn - 1 - seen
        end
    end
    return last_value
end


using ReTest

@testset "day15" begin
    @testset "example" begin
        @testset for g in (game, game_mixed, game_vector)
            @test g([0, 3, 6], 2020) == 436
            @test g([0, 3, 6], 3*10^7) == 175594
        end
    end

    @testset "bench" begin
        input = [14,1,17,0,3,20]
        @eval using BenchmarkTools
        @info "Day 15"
        @eval begin
            @btime game_mixed($input, 2020)
            @btime game_mixed($input, 3*10^7)
        end
    end
end

end
