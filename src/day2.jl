"""
--- Day 2: Password Philosophy ---

Your flight departs in a few days from the coastal airport; the easiest way down to the coast from here is via toboggan.

The shopkeeper at the North Pole Toboggan Rental Shop is having a bad day. "Something's wrong with our computers; we can't log in!" You ask if you can take a look.

Their password database seems to be a little corrupted: some of the passwords wouldn't have been allowed by the Official Toboggan Corporate Policy that was in effect when they were chosen.

To try to debug the problem, they have created a list (your puzzle input) of passwords (according to the corrupted database) and the corporate policy when that password was set.

For example, suppose you have the following list:

1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc

Each line gives the password policy and then the password. The password policy indicates the lowest and highest number of times a given letter must appear for the password to be valid. For example, 1-3 a means that the password must contain a at least 1 time and at most 3 times.

In the above example, 2 passwords are valid. The middle password, cdefg, is not; it contains no instances of b, but needs at least 1. The first and third passwords are valid: they contain one a or nine c, both within the limits of their respective policies.
"""
module day2

function get_input()
    map(readlines("data/day2")) do line
        policy, pass = split(line, ": ")
        lohi, (char,) = split(policy)
        lohi = parse.(Int, split(lohi, "-"))
        return lohi, char, pass
    end
end

"""
How many passwords are valid according to their policies?
"""
function part1(input)
    count(input) do ((lo, hi), char, pass)
        count(==(char), pass) in lo:hi
    end
end

"""
Each policy actually describes two positions in the password, where 1 means the first character, 2 means the second character, and so on. (Be careful; Toboggan Corporate Policies have no concept of "index zero"!) Exactly one of these positions must contain the given letter. Other occurrences of the letter are irrelevant for the purposes of policy enforcement.

Given the same example list from above:

    1-3 a: abcde is valid: position 1 contains a and position 3 does not.
    1-3 b: cdefg is invalid: neither position 1 nor position 3 contains b.
    2-9 c: ccccccccc is invalid: both position 2 and position 9 contain c.

How many passwords are valid according to the new interpretation of the policies?
"""
function part2(input)
    count(input) do ((lo, hi), char, pass)
        (pass[lo] == char) ⊻ (pass[hi] == char)
    end
end

using ReTest

@testset "bench" begin
    @eval using BenchmarkTools
    @eval begin
        input = get_input()
        @info "Day 2"
        @btime part1($input)
        @btime part2($input)
        println()
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = get_input()
    @show part1(input)
    @show part2(input)
end

end
