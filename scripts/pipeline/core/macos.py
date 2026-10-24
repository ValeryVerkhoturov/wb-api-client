import subprocess

from .proc import run


def dequarantine_and_sign(home, binary):
    for command in (
        ["xattr", "-cr", home],
        ["codesign", "--force", "--sign", "-", binary],
    ):
        try:
            run(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except OSError:
            pass
    for dylib in (home / "bin").glob("*.dylib"):
        try:
            run(
                ["codesign", "--force", "--sign", "-", dylib],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError:
            pass
