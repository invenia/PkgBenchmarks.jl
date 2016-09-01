module PkgBenchmarks

using BenchmarkTools
using Base.LibGit2

export benchmark, trial

include("pkg.jl")
include("libgit2.jl")
include("report.jl")

end # module
