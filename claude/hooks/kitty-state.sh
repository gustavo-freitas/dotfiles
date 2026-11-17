#!/bin/sh
# Report Claude Code state to kitty as a window user var (claude_state).
# Usage: kitty-state.sh idle|busy|attention|clear
#
# Sessions run by the background daemon ("claude bg-spare") have no
# KITTY_WINDOW_ID. For those, map the hook's session_id (stdin JSON) to the
# interactive client whose parkedJobId matches, and use that client's window.
win="$KITTY_WINDOW_ID"
if [ -z "$win" ]; then
  win=$(python3 -I -c '
import glob, json, sys
try:
    sid = json.load(sys.stdin).get("session_id", "")
except Exception:
    sys.exit()
if not sid:
    sys.exit()
for f in glob.glob(glob.os.path.expanduser("~/.claude/sessions/*.json")):
    try:
        s = json.load(open(f))
        if s.get("kind") != "interactive" or not sid.startswith(s.get("parkedJobId") or "\0"):
            continue
        env = open("/proc/%d/environ" % s["pid"], "rb").read().split(b"\0")
    except Exception:
        continue
    for e in env:
        if e.startswith(b"KITTY_WINDOW_ID="):
            print(e.split(b"=", 1)[1].decode())
            sys.exit()
' 2>/dev/null)
fi
[ -n "$win" ] || exit 0
case "$1" in
  clear) var="claude_state" ;;   # no "=" unsets the var
  *)     var="claude_state=$1" ;;
esac
exec kitten @ set-user-vars --match "id:$win" "$var" >/dev/null 2>&1
