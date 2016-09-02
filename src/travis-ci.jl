using Requests

function travis_benchmark(slug, token, pkg, baseline, candidate)
    slug = replace(slug, "/", "%2F")

    # Using the Travis API v3 beta
    # https://docs.travis-ci.com/user/triggering-builds
    body = Dict(
        "request" => Dict(
            "message" => "Performance benchmark test: \"$baseline\" vs. \"$candidate\"",
            "branch" => candidate,
            "config" => Dict(
                "os" => "linux",  # Guess we don't have to restrict the OS
                "julia" => "nightly",  # Need LibGit2 support (in 0.5+)
                "env" => Dict(
                    "matrix" => ["TEST=performance"],  # For future use
                ),
                "install" => [
                    "git remote set-branches origin $baseline $candidate",
                    "if [[ -a .git/shallow ]]; then git fetch --unshallow; fi",
                    "julia -e 'Pkg.init(); symlink(pwd(), Pkg.dir(\"$pkg\")); Pkg.resolve(); Pkg.build(\"$pkg\");'",
                    "julia -e 'Pkg.clone(\"https://github.com/invenia/PkgBenchmarks.jl\"); Pkg.checkout(\"PkgBenchmarks\", \"travis-ci\");'",  # Temporary
                    "julia -e 'Pkg.add(\"BenchmarkTools\");'",  # Should be handled by a REQUIRE file
                ],
                "script" => [
                    # TODO: Cause failure upon finding any regression
                    "julia -e 'using PkgBenchmarks, BenchmarkTools; run(`git checkout $baseline`); run(`git rev-parse HEAD`); b = benchmark(\"$pkg\"); run(`git checkout $candidate`); run(`git rev-parse HEAD`); a = benchmark(\"$pkg\"); println(leaves(judge(minimum(a), minimum(b)))); showall(a); showall(b);'",
                ],
                "after_success" => "echo hi",  # TODO: find a better way to override "after_success"
            ),
        )
    )

    post(
        "https://api.travis-ci.org/repo/$slug/requests",
        json = body,
        headers = Dict(
            "Travis-API-Version" => "3",
            "Authorization" => "token \"$token\"",
        ),
    )
end
