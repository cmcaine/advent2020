# For some reason `using advent2020` disables all the tests.
include(joinpath(dirname(@__DIR__), "src", "advent2020.jl"))

using ReTest

if isempty(ARGS)
    runtests(r"/d")
else
    runtests(first(ARGS))
end
