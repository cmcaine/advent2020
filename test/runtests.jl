basepath = "$(@__DIR__)/../src/"

for day in 1:25
    path = joinpath(basepath, "day$day.jl")
    isfile(path) && include(path)
end

using ReTest

runtests(r"/d")
