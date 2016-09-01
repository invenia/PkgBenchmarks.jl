# PkgBenchmarks

[![Build Status](https://travis-ci.org/omus/PkgBenchmarks.jl.svg?branch=master)](https://travis-ci.org/omus/PkgBenchmarks.jl)

[![Coverage Status](https://coveralls.io/repos/omus/PkgBenchmarks.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/omus/PkgBenchmarks.jl?branch=master)

[![codecov.io](http://codecov.io/github/omus/PkgBenchmarks.jl/coverage.svg?branch=master)](http://codecov.io/github/omus/PkgBenchmarks.jl?branch=master)

A quick example:

```julia
julia> using BenchmarkTools

julia> using PkgBenchmarks

julia> a, b = trial("TimeZones", "master", "regression");
INFO: Benchmarking baseline
(1/1) benchmarking "parse"...
  (1/1) benchmarking "multiple"...
  done (took 5.484268865 seconds)
done (took 5.652773505 seconds)
INFO: Benchmarking candidate
(1/1) benchmarking "parse"...
  (1/1) benchmarking "multiple"...
  done (took 7.896175863 seconds)
done (took 8.069294301 seconds)

julia> regs = regressions(judge(minimum(a), minimum(b)));

julia> pairs = leaves(regs)
1-element Array{Any,1}:
 (Any["parse","multiple"],BenchmarkTools.TrialJudgement: 
  time:   +14669.85% => regression (5.00% tolerance)
  memory: +15914.09% => regression (1.00% tolerance))
```