#
# Code adapted from: [Nanosoldier.jl](https://github.com/JuliaCI/Nanosoldier.jl)
# See: src/jobs/BenchmarkJob.jl
#
# Reporting should probably be moved into BenchmarkTooks.jl or into a package separate from
# Nanosoldier.jl
#
# Note: Only minimal changes have been done to the reporting code.

const REGRESS_MARK = ":x:"
const IMPROVE_MARK = ":white_check_mark:"

function printreport(io::IO, judged)
    # print result table #
    #--------------------#

    iscomparisonjob = true
    tablegroup = judged

    println(io, """
                ## Results
                *Note: If Chrome is your browser, I strongly recommend installing the [Wide GitHub](https://chrome.google.com/webstore/detail/wide-github/kaalofacklcidaampbokdplbklpeldpj?hl=en)
                extension, which makes the result table easier to read.*
                Below is a table of this job's results, obtained by running the benchmarks found in
                [JuliaCI/BaseBenchmarks.jl](https://github.com/JuliaCI/BaseBenchmarks.jl). The values
                listed in the `ID` column have the structure `[parent_group, child_group, ..., key]`,
                and can be used to index into the BaseBenchmarks suite to retrieve the corresponding
                benchmarks.
                The percentages accompanying time and memory values in the below table are noise tolerances. The "true"
                time/memory value for a given benchmark is expected to fall within this percentage of the reported value.
                """)

    if iscomparisonjob
        print(io, """
                  A ratio greater than `1.0` denotes a possible regression (marked with $(REGRESS_MARK)), while a ratio less
                  than `1.0` denotes a possible improvement (marked with $(IMPROVE_MARK)). Only significant results - results
                  that indicate possible regressions or improvements - are shown below (thus, an empty table means that all
                  benchmark results remained invariant between builds).
                  | ID | time ratio | memory ratio |
                  |----|------------|--------------|
                  """)
    else
        print(io, """
                  | ID | time | GC time | memory | allocations |
                  |----|------|---------|--------|-------------|
                  """)
    end

    entries = BenchmarkTools.leaves(tablegroup)

    try
        entries = entries[sortperm(map(x -> string(first(x)), entries))]
    end

    for (ids, t) in entries
        if !(iscomparisonjob) || BenchmarkTools.isregression(t) || BenchmarkTools.isimprovement(t)
            println(io, resultrow(ids, t))
        end
    end

    println(io)

    # print list of executed benchmarks #
    #-----------------------------------#
    println(io, """
                ## Benchmark Group List
                Here's a list of all the benchmark groups executed by this job:
                """)

    for id in unique(map(pair -> pair[1][1:end-1], entries))
        println(io, "- `", idrepr(id), "`")
    end

    println(io)

    # # print build version info #
    # #--------------------------#
    # print(io, """
    #           ## Version Info
    #           #### Primary Build
    #           ```
    #           $(build.vinfo)
    #           ```
    #           """)

    # if hasagainstbuild
    #     println(io)
    #     print(io, """
    #               #### Comparison Build
    #               ```
    #               $(get(job.against).vinfo)
    #               ```
    #               """)
    # end
    return nothing
end

idrepr(id) = (str = repr(id); str[searchindex(str, '['):end])

intpercent(p) = string(ceil(Int, p * 100), "%")

resultrow(ids, t::BenchmarkTools.Trial) = resultrow(ids, minimum(t))

function resultrow(ids, t::BenchmarkTools.TrialEstimate)
    t_tol = intpercent(BenchmarkTools.params(t).time_tolerance)
    m_tol = intpercent(BenchmarkTools.params(t).memory_tolerance)
    timestr = string(BenchmarkTools.prettytime(BenchmarkTools.time(t)), " (", t_tol, ")")
    memstr = string(BenchmarkTools.prettymemory(BenchmarkTools.memory(t)), " (", m_tol, ")")
    gcstr = BenchmarkTools.prettytime(BenchmarkTools.gctime(t))
    allocstr = string(BenchmarkTools.allocs(t))
    return "| `$(idrepr(ids))` | $(timestr) | $(gcstr) | $(memstr) | $(allocstr) |"
end

function resultrow(ids, t::BenchmarkTools.TrialJudgement)
    t_tol = intpercent(BenchmarkTools.params(t).time_tolerance)
    m_tol = intpercent(BenchmarkTools.params(t).memory_tolerance)
    t_ratio = @sprintf("%.2f", BenchmarkTools.time(BenchmarkTools.ratio(t)))
    m_ratio =  @sprintf("%.2f", BenchmarkTools.memory(BenchmarkTools.ratio(t)))
    t_mark = resultmark(BenchmarkTools.time(t))
    m_mark = resultmark(BenchmarkTools.memory(t))
    timestr = "$(t_ratio) ($(t_tol)) $(t_mark)"
    memstr = "$(m_ratio) ($(m_tol)) $(m_mark)"
    return "| `$(idrepr(ids))` | $(timestr) | $(memstr) |"
end

resultmark(sym::Symbol) = sym == :regression ? REGRESS_MARK : (sym == :improvement ? IMPROVE_MARK : "")
