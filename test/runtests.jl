# For some reason `using advent2020` disables all the tests.
include(joinpath(dirname(@__DIR__), "src", "advent2020.jl"))

using ReTest

if isempty(ARGS)
    # Run the tests, but not the benchmarks
    runtests(r"/day\d{1,2}/[^b]")
else
    runtests(Regex(first(ARGS)))
end
