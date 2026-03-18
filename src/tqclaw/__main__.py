# -*- coding: utf-8 -*-
"""Allow running TQ-Claw via ``python -m tqclaw``."""
from .cli.main import cli

if __name__ == "__main__":
    cli()  # pylint: disable=no-value-for-parameter
