"""Domain-driven layout of the wb-api-client codegen pipeline.

Bounded contexts:
  core       — shared kernel: repo paths, naming/identity, YAML IO, subprocess
  specs      — spec acquisition (download) and transformation (post-process)
  generation — client generation orchestration and secret-string injection
  onescript  — OneScript runtime/plugin toolchain, manifests, compile check
  docs       — docs-site API reference and per-language READMEs

The flat scripts/*.py files are thin CLI shims over these modules, so the
Makefile, CI workflows and README command lines keep working unchanged.
"""
