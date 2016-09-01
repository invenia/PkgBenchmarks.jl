function trial(pkg::AbstractString, baseline::AbstractString, candidate::AbstractString="HEAD")
    repo = LibGit2.GitRepo(Pkg.dir(pkg))
    org_head = LibGit2.head_oid(repo)

    checkout_safe!(repo, candidate)
    trial_candidate = benchmark(pkg)

    checkout_safe!(repo, baseline)
    trial_baseline = benchmark(pkg)

    checkout_safe!(repo, org_head)
    return trial_candidate, trial_baseline
end

function benchmark(pkg::AbstractString)
    results_file = tempname()
    touch(results_file)
    code = """
        using BenchmarkTools
        open("$(escape_string(results_file))", "w") do f
            pkg = first(ARGS)
            suite = include(Pkg.dir(pkg, "test", "performance.jl"))
            results = run(suite, verbose=true)
            serialize(f, results)
        end
    """
    cmd = `$(Base.julia_cmd()) --eval $code $pkg`
    io, pobj = open(pipeline(detach(cmd), stderr=STDERR), "w", STDOUT)

    wait(pobj)
    close(io)
    results = open(results_file, "r") do f
       deserialize(f)
    end
    isfile(results_file) && rm(results_file)
    return results
end