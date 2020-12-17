module day13

function get_input(str=read("data/day13", String))
    ts, buses = split(str)
    ts = parse(Int, ts)
    buses = parse.(Int, filter(!=("x"), split(buses, ',')))
    ts, buses
end

function get_input2(str=read("data/day13", String))
    _, buses = split(str)
    vs = filter(enumerate(split(buses, ',')) |> collect) do (offset, bus_id)
        bus_id != "x"
    end
    map(vs) do (offset, bus_id)
        parse(Int, bus_id), offset-1
    end |> vs -> sort!(vs; rev=true)
end

# From 2-arg argmax PR by me and @tkf
Base.findmin(f, domain) = mapfoldl(x -> (f(x), x), _rf_findmin, domain)
_rf_findmin((fm, m), (fx, x)) = isgreater(fm, fx) ? (fx, x) : (fm, m)
isgreater(x, y) = is_poisoning(x) || is_poisoning(y) ? isless(x, y) : isless(y, x)
is_poisoning(x) = false
is_poisoning(x::AbstractFloat) = isnan(x)
is_poisoning(x::Missing) = true

function part1((ts, buses))
    findmin(buses) do bus
        bus - ts % bus
    end |> prod
end

# Too slow!
function part2(vs)
    biggest, biggest_offset = first(vs)
    rest = @view vs[2:end]
    for t in 0:biggest:100000000000000
        t -= biggest_offset
        found = true
        for (bus, offset) in rest
            t′ = t + offset
            t′ % bus == 0 || (found = false; break)
        end
        found && return t
    end
    error("!")
end

end
