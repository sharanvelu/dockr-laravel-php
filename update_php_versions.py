#!/usr/bin/env python3

import re
import subprocess
from datetime import datetime, timedelta, timezone
from time import sleep

import requests
from packaging.version import Version

DOCKERFILE_PATH = "Dockerfile"
REPO_URL = "https://hub.docker.com/v2/repositories/library/php/tags"
TAG_PATTERN = re.compile(r"^(\d+\.\d+\.\d+)-fpm-alpine$")

DURATION_IN_HOURS = 24

def fetch_php_tags():
    tags = []
    url = REPO_URL
    params = {"page_size": 100, "ordering": "last_updated"}
    cutoff = datetime.now(timezone.utc) - timedelta(hours=DURATION_IN_HOURS)

    while url:
        resp = requests.get(url, params=params)
        resp.raise_for_status()
        data = resp.json()

        for tag in data.get("results", []):
            last_updated = datetime.fromisoformat(tag["last_updated"].replace("Z", "+00:00"))
            if last_updated < cutoff:
                return sorted(set(tags), key=Version)

            name = tag["name"]
            match = TAG_PATTERN.match(name)
            if match:
                tags.append(match.group(1))

        url = data.get("next")
        params = {}

    return sorted(set(tags), key=Version)


def run(cmd, check=True):
    print(f"  $ {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if check and result.returncode != 0:
        print(f"    FAILED: {result} | {result.stderr.strip()}")
        return False
    return True


def update_dockerfile(version):
    with open(DOCKERFILE_PATH, "r") as f:
        content = f.read()

    new_content = re.sub(
        r"^ARG PHP_VERSION=.*$",
        f"ARG PHP_VERSION={version}",
        content,
        count=1,
        flags=re.MULTILINE,
    )

    with open(DOCKERFILE_PATH, "w") as f:
        f.write(new_content)


def process_version(version):
    branch = f"php-{version}"
    print(f"\nProcessing PHP {version} (branch: {branch})")
    return

    run("git checkout template")
    run(f"git branch -D {branch}", check=False)
    run(f"git checkout -b {branch}")

    update_dockerfile(version)

    run(f"git add {DOCKERFILE_PATH}")
    sleep(1)
    run(f'git commit -m "Updated image for PHP version {version}"')

    run(f"git push origin {branch} --force")
    run("git checkout template")
    run(f"git branch -D {branch}", check=False)


def main():
    print("Fetching PHP tags from Docker Hub...")
    versions = fetch_php_tags()

    if not versions:
        print(f"No PHP versions updated in the last {DURATION_IN_HOURS} hours")
        return

    print(f"Found {len(versions)} versions updated in the last {DURATION_IN_HOURS} hours:")
    for v in versions:
        print(f"  - {v}")

    for version in versions:
       process_version(version)

    print("\nDone!")


if __name__ == "__main__":
    main()
