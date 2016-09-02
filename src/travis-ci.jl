using Requests

function travis_benchmark(slug, token, pkg, baseline, candidate)
    slug = replace(slug, "/", "%2F")

    # Using the Travis API v3 beta. Documentation currently unreleased.
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
                ],
                "script" => [
                    "julia -e 'using PkgBenchmarks, BenchmarkTools; a, b = benchmark(\"$pkg\", \"$baseline\", \"$candidate\"); j = judge(minimum(a), minimum(b)); println(leaves(j)); showall(a); showall(b); exit(!isempty(regressions(j)))'",
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
