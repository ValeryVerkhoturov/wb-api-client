from .proc import run


def clone_at(repo, ref, dest):
    run(
        ["git", "-c", "advice.detachedHead=false", "clone", "--quiet", repo, dest],
        check=True,
    )
    run(
        [
            "git",
            "-C",
            dest,
            "-c",
            "advice.detachedHead=false",
            "checkout",
            "--quiet",
            ref,
        ],
        check=True,
    )
