#!/usr/bin/env python3

import os
import sys
from pathlib import Path

def main(filename: str) -> None:
    icon, size = Path(filename), 1024

    while size >= 16:
        os.system(f"inkscape {icon} -w {size} -h {size} -o {icon.stem}-{size}x{size}.png")
        size //= 2

if __name__ == '__main__':
    main(sys.argv[1])

