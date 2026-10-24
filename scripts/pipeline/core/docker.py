import os

from .proc import run


def docker_run(
    image, args, *, mounts=(), workdir=None, env=(), entrypoint=None, **kwargs
):
    cmd = ["docker", "run", "--rm", "-u", f"{os.getuid()}:{os.getgid()}"]
    for mount in mounts:
        cmd += ["-v", mount]
    if workdir:
        cmd += ["-w", workdir]
    for var in env:
        cmd += ["-e", var]
    if entrypoint:
        cmd += ["--entrypoint", entrypoint]
    return run([*cmd, image, *args], **kwargs)
