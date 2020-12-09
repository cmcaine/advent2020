module day7

"""
This is the first time I've ever recorded myself programming, and this video is mostly for me to track and improve my programming, but maybe it'll interest others!I am sorry about the incomplete sentences, clacky keyboard and other bad bits, tho. Leave kind feedback below, if you like :)

Before recording the video I read the problem description for part 1 and thought about it while I walked my dog. I hadn't read any other solutions or commentary.

I was hoping to finish in 20-30 minutes but took about 90, so that's not great. I think I could have saved maybe 30 minutes by reading the problem descriptions more carefully and avoiding regex in the input processing step.

The timeline is roughly this:

0-
13:00 - trying to load data, dead end with regexes
25:00 - got data loaded in a simple way
44:00 - got data loaded as a SimpleDiGraph
58:00 - solved part 1
1:15:00 - solved part 2 (wasted some time solving the wrong problem for each one)
1:32:00 - cleaned some things up and faffed around
"""

# Input is an adjacency list for a weighted directed graph where nodes are bags of a given colour and edges show how many bags of what other colour they must contain.
# Our task is to find all the bag colours that could contain our **shiny gold bag**.

using LightGraphs
using SimpleWeightedGraphs

function invert(dict::AbstractDict)
    Dict(reverse(p) for p in pairs(dict))
end

function get_input(str=read("data/day7", String))
    g = SimpleWeightedDiGraph{Int, Int}()
    names_to_nodes = Dict()
    function ensure_bag_node(str)
        default = length(vertices(g))+1
        res = get!(names_to_nodes, str, default)
        res == default && add_vertex!(g)
        return res
    end
    for line in split(str, '\n', keepempty=false)
        thisbag, rest = split(line, " bags contain "; limit=2)
        src_node = ensure_bag_node(thisbag)
        rest == "no other bags." && continue
        edges = map(split(rest, r" bags?(, |.)", keepempty=false)) do edge
            weight, destination = split(edge; limit=2)
            weight = parse(Int, weight)
            dst_node = ensure_bag_node(destination)
            add_edge!(g, src_node, dst_node, weight) || error("Couldn't add edge! ", join((thisbag, destination, dst_node, length(g), src_node), ", "))
        end
    end
    g, names_to_nodes, invert(names_to_nodes)
end


function nodes_in_inverse_tree(g, start)
    neigh = inneighbors(g, start)
    isempty(neigh) && return start
    union(start, (nodes_in_inverse_tree(g, v) for v in neigh)...)
end

function bags_in_bag(g, start)
    num_bags = 0
    for v in neighbors(g, start)
        if has_edge(g, start, v)
            num_bags += g.weights[v, start] * (1 + bags_in_bag(g, v))
        end
    end
    return num_bags
end


function part1(g, ntn, intn)
    ourbag = ntn["shiny gold"]
    treenodes = nodes_in_inverse_tree(g, ourbag)
    return length(treenodes)-1
end

function part2(g, ntn, intn)
    ourbag = ntn["shiny gold"]
    return bags_in_bag(g, ourbag)
end


using ReTest

@testset "examples" begin
    input =
        """
        light red bags contain 1 bright white bag, 2 muted yellow bags.
        dark orange bags contain 3 bright white bags, 4 muted yellow bags.
        bright white bags contain 1 shiny gold bag.
        muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
        shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
        dark olive bags contain 3 faded blue bags, 4 dotted black bags.
        vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
        faded blue bags contain no other bags.
        dotted black bags contain no other bags.
        """
    g, ntn, intn = get_input(input)
    @test part1(g, ntn, intn) == 4
    @test part2(g, ntn, intn) == 2
end

if abspath(PROGRAM_FILE) == @__FILE__
    input = get_input()
    @show part1(input)
    @show part2(input)
end

end
