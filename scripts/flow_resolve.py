#!/usr/bin/env python3
import os
import stat
import subprocess
import sys
import time
from pathlib import Path

import yaml


def find_flowfile(start: Path) -> Path | None:
    d = start
    while True:
        fp = d / ".flow.yml"
        if fp.exists():
            return fp
        if d.parent == d:
            return None
        d = d.parent


def repo_name_for_dir(filedir: Path) -> str:
    try:
        out = subprocess.run(
            ["git", "-C", str(filedir), "rev-parse", "--show-toplevel"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=1.0,
        )
    except Exception:
        return ""

    repo_full = (out.stdout or "").strip()
    return repo_full.split("/")[-1] if repo_full else ""


def pick_cmd_def(flow_defs: dict, filepath: Path) -> dict | None:
    basename = filepath.name
    filename = filepath.stem
    ext = filepath.suffix
    filedir = filepath.parent
    folder = filedir.name
    repo_name = repo_name_for_dir(filedir)

    cmd_def = flow_defs.get("default")

    if basename in flow_defs:
        cmd_def = flow_defs[basename]
    elif folder in flow_defs:
        cmd_def = flow_defs[folder]
    elif repo_name and repo_name in flow_defs:
        cmd_def = flow_defs[repo_name]
    elif filename in flow_defs:
        cmd_def = flow_defs[filename]
    elif ext in flow_defs:
        cmd_def = flow_defs[ext]
    elif ext.replace(".", "") in flow_defs:
        cmd_def = flow_defs[ext.replace(".", "")]

    if cmd_def is None:
        return None

    cmd = cmd_def.get("cmd", "").strip()
    cmd = cmd.replace("{{filepath}}", str(filepath))
    cmd = cmd.replace("{{dir}}", str(filedir))
    if not cmd.startswith("#!"):
        cmd = "#!/usr/bin/env bash\n" + cmd

    return {**cmd_def, "cmd": cmd}


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: flow_resolve.py <filepath>", file=sys.stderr)
        return 2

    filepath = Path(sys.argv[1]).expanduser().resolve()
    if not filepath.exists():
        print(f"file not found: {filepath}", file=sys.stderr)
        return 2

    flowfile = find_flowfile(filepath.parent)
    if flowfile is None:
        print("No `.flow.yml` found...", file=sys.stderr)
        return 1

    try:
        flow_defs = yaml.safe_load(flowfile.read_text())
    except Exception as e:
        print(f"failed to parse {flowfile}: {e}", file=sys.stderr)
        return 1

    cmd_def = pick_cmd_def(flow_defs or {}, filepath)
    if cmd_def is None:
        print("no valid command definitions found in `.flow.yml`", file=sys.stderr)
        return 1

    script_path = Path(f"/tmp/flow--{int(time.time())}")
    script_path.write_text(cmd_def["cmd"] + "\n")
    st = os.stat(script_path)
    os.chmod(script_path, st.st_mode | stat.S_IEXEC)

    print(str(script_path))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
