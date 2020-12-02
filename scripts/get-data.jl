using HTTP

aoc_cookie = read("cookie", String) |> strip

function get_data(day)
    response = HTTP.get("https://adventofcode.com/2020/day/$day/input", cookies = Dict("session" => aoc_cookie))
    response.status != 200 && error(response)
    response.body
end

function download_input(day)
    data = get_data(day)
    path = joinpath(dirname(@__DIR__), "data/day$day")
    write(path, data)
end

if abspath(PROGRAM_FILE) == @__FILE__
    download_input(first(ARGS))
end
