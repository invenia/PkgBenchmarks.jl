"""
    benchmark(pkg, baseline, candidate="HEAD") -> Tuple{BenchmarkGroup,BenchmarkGroup}

Runs the package benchmarks for the Git revisions `baseline` and `candidate` and returns the
results. Package are expected to have a "bench/benchmarks.jl" file which returns the
benchmark suite.
"""
function benchmark(pkg::AbstractString, baseline::AbstractString, candidate::AbstractString="HEAD")
    repo = LibGit2.GitRepo(Pkg.dir(pkg))
    org_head = LibGit2.head_oid(repo)

    info("Benchmarking baseline ($baseline)")
    checkout_safe!(repo, baseline)
    println(string(LibGit2.head_oid(repo)))  # Show SHA
    trial_baseline = benchmark(pkg)

    info("Benchmarking candidate ($candidate)")
    checkout_safe!(repo, candidate)
    println(string(LibGit2.head_oid(repo)))  # Show SHA
    trial_candidate = benchmark(pkg)

    checkout_safe!(repo, org_head)
    return trial_candidate, trial_baseline
end

function benchmark(pkg::AbstractString)
    results_file = tempname()
    touch(results_file)
    code = """
        using BenchmarkTools
        open("$(escape_string(results_file))", "w") do f
            suite = include(Pkg.dir("$(escape_string(pkg))", "bench", "benchmarks.jl"))
            results = run(suite, verbose=true)
            serialize(f, results)
        end
    """
    results = try
        # TODO: We may want to allow re-building the package between runs
        run(`$(Base.julia_cmd()) --compilecache=no --eval $code`)
        open(results_file, "r") do f
            deserialize(f)
        end
    finally
        isfile(results_file) && rm(results_file)
    end

    return results
end
