# PkgBenchmarks

[![Build Status](https://travis-ci.org/omus/PkgBenchmarks.jl.svg?branch=master)](https://travis-ci.org/omus/PkgBenchmarks.jl)

[![Coverage Status](https://coveralls.io/repos/omus/PkgBenchmarks.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/omus/PkgBenchmarks.jl?branch=master)

[![codecov.io](http://codecov.io/github/omus/PkgBenchmarks.jl/coverage.svg?branch=master)](http://codecov.io/github/omus/PkgBenchmarks.jl?branch=master)

A quick example:

```julia
julia> using BenchmarkTools

julia> using PkgBenchmarks

julia> a, b = trial("TimeZones", "regression", "improvement");
INFO: Benchmarking baseline (regression)
(1/1) benchmarking "parse"...
  (1/1) benchmarking "multiple"...
  done (took 7.974803644 seconds)
done (took 8.150638788 seconds)
INFO: Benchmarking candidate (improvement)
(1/1) benchmarking "parse"...
  (1/1) benchmarking "multiple"...
  done (took 5.508084035 seconds)
done (took 5.673741745 seconds)

julia> regs = regressions(judge(minimum(a), minimum(b)));

julia> pairs = leaves(regs)
0-element Array{Any,1}

julia> pairs = leaves(judge(minimum(a), minimum(b)))
1-element Array{Any,1}:
 (Any["parse","multiple"],BenchmarkTools.TrialJudgement: 
  time:   -99.31% => improvement (5.00% tolerance)
  memory: -99.38% => improvement (1.00% tolerance))

```