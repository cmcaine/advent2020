module advent2020

for day in 1:25
    path = joinpath(@__DIR__, "day$day.jl")
    isfile(path) && include(path)
end

end
