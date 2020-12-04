module day4

function get_input(str=read("data/day4", String))
    documents = split(str, "\n\n")
    map(documents) do doc
        map(m -> m.captures, eachmatch(r"(\w+):(\S+)", doc))
    end
end

function part1(passports)
    count(passports) do passport
        first.(passport) ⊇ ("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid")
    end
end

# Do a bunch of tedious validation of the fields.
function part2(passports)
    count(passports) do pp
        pp = filter( ((f, v),) -> f != "cid", pp )
        count(validate_field, pp) == 7
    end
end

function validate_field((field, value))
    if field == "byr"
        parse(Int, value) in 1920:2002
    elseif field == "iyr"
        parse(Int, value) in 2010:2020
    elseif field == "eyr"
        parse(Int, value) in 2020:2030
    elseif field == "hgt"
        x() = parse(Int, @view value[1:end-2])
        endswith(value, "in") && (x() in 59:76) ||
            endswith(value, "cm") && (x() in 150:193)
    elseif field == "hcl"
        occursin(r"^#[0-9a-f]{6}$", value)
    elseif field == "ecl"
        value in ("amb", "blu", "brn", "gry", "grn", "hzl", "oth")
    elseif field == "pid"
        occursin(r"^\d{9}$", value)
    else
        field == "cid"
    end
end


using ReTest

@testset "day4" begin
    @testset "examples" begin
        input = """
                ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
                byr:1937 iyr:2017 cid:147 hgt:183cm

                iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
                hcl:#cfa07d byr:1929

                hcl:#ae17e1 iyr:2013
                eyr:2024
                ecl:brn pid:760753108 byr:1931
                hgt:179cm

                hcl:#cfa07d eyr:2025 pid:166559648
                iyr:2011 ecl:brn hgt:59in
                """
        x = get_input(input)
        @test part1(x) == 2
        valid_passports =
            """
            pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
            hcl:#623a2f

            eyr:2029 ecl:blu cid:129 byr:1989
            iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

            hcl:#888785
            hgt:164cm byr:2001 iyr:2015 cid:88
            pid:545766238 ecl:hzl
            eyr:2022

            iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
            """
        invalid_passports =
            """
            eyr:1972 cid:100
            hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

            iyr:2019
            hcl:#602927 eyr:1967 hgt:170cm
            ecl:grn pid:012533040 byr:1946

            hcl:dab227 iyr:2012
            ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

            hgt:59cm ecl:zzz
            eyr:2038 hcl:74454a iyr:2023
            pid:3556412378 byr:2007

            iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:0931547191

            iyr:2010 hgt:158 hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
            """
        @test part2(get_input(valid_passports)) == 4
        @test part2(get_input(invalid_passports)) == 0
    end

    @testset "bench" begin
        @eval using BenchmarkTools
        @eval begin
            input = get_input()
            @info "Day 4"
            @btime part1(input)
            @btime part2(input)
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
