#!/usr/bin/env python3
"""Backwards-compatible import path — implementation moved to
pipeline/onescript/toolchain.py. Kept so existing `from onescript_toolchain
import …` callers (and docs referencing this filename) keep working.
"""
from pipeline.onescript.toolchain import (  # noqa: F401
    ONESCRIPT_CODEGEN_REF,
    ONESCRIPT_CODEGEN_REPO,
    ONESCRIPT_CONNECTOR_VERSION,
    ONESCRIPT_JASON_VERSION,
    ONESCRIPT_VERSION,
    ensure_onescript,
    ensure_onescript_package,
    ensure_onescript_plugin,
    onescript_platform,
)
