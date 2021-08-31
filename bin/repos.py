#!/usr/bin/env python3

from __future__ import annotations

import subprocess
from typing import List

import requests

def get_user_repos() -> List[str]:
    command = subprocess.run(["git", "config", "--global", "user.name"], capture_output=True, text=True)
    username = command.stdout.strip('\n')
    with requests.get(f"https://api.github.com/users/{username}/repos") as response:
        names = [item['full_name'] for item in response.json()]
        return list(map(lambda full_name: f"git@github.com:{full_name}.git", names))


if __name__ == '__main__':
    repos = get_user_repos()
    print('\n'.join(repos))

