#
# Functionality that should be eventually included in Base.LibGit2
#

"""
    checkout_safe!(repo::GitRepo, rev::AbstractString) -> nothing

Checks out a revision from a Git repository. The `rev` can be a branch, tag, SHA, or partial
SHA. Meant to be a temporary workaround to deal with limitations of `LibGit2.checkout!`
"""
function checkout_safe!(repo::LibGit2.GitRepo, rev::AbstractString)
    # Avoid using `checkout!` unless the repo has no uncommitted changes
    length(LibGit2.GitStatus(repo)) == 0 || error("Repo has uncommited changes")

    # TODO: `revparseid` issues:
    # - Doesn't notice ambiguous revisions. i.e. a tag with the same name as a branch.
    #   Issue could be from the `libgit2` library.
    oid = LibGit2.revparseid(repo, rev)

    # TODO: `checkout!` seems broken in multiple ways including:
    # - Only uses full SHAs. Can not use tags, branches, or partial SHAs
    # - Defaults to using a `force=true` which wipes out any uncommited changes
    # - Using `force=false` seems to always fail
    LibGit2.checkout!(repo, string(oid), force=true)
end

function checkout_safe!(repo::LibGit2.GitRepo, oid::Base.LibGit2.Oid)
    length(LibGit2.GitStatus(repo)) == 0 || error("Repo has uncommited changes")
    LibGit2.checkout!(repo, string(oid), force=true)
end

function checkout_safe!(repo::AbstractString, rev::AbstractString)
    # Avoid LibGit2 altogether...
    run(`git --git-dir $(joinpath(repo, ".git")) checkout $rev`)
end

function sha(repo::AbstractString, rev::AbstractString="HEAD")
    readchomp(`git --git-dir $(joinpath(repo, ".git")) rev-parse $rev`)
end
