#!/usr/bin/env bash
# Runs every test scene in tests/ headless at a fixed 60 fps and prints one summary line per suite plus a total.
#   tools/run_tests.sh [godot-binary] [pattern]
# Exit code: 0 if every suite exits 0. Logs go to $TMPDIR/final_thaw_tests/<suite>.log (outside the repository).
GODOT="${1:-godot}"
PATTERN="${2:-test_}"
cd "$(dirname "$0")/.." || exit 2
LOGDIR="${TMPDIR:-/tmp}/final_thaw_tests"
mkdir -p "$LOGDIR"
"$GODOT" --headless --path . --import > "$LOGDIR/_import.log" 2>&1
failed=0
total_pass=0
total_fail=0
for scene in tests/${PATTERN}*.tscn; do
	name="$(basename "$scene" .tscn)"
	timeout 900 "$GODOT" --headless --fixed-fps 60 --path . "res://$scene" > "$LOGDIR/$name.log" 2>&1
	code=$?
	pass=$(grep -c "^PASS" "$LOGDIR/$name.log")
	fail=$(grep -c "FAIL" "$LOGDIR/$name.log")
	errs=$(grep -c "SCRIPT ERROR\|Parse Error" "$LOGDIR/$name.log")
	total_pass=$((total_pass + pass))
	total_fail=$((total_fail + fail))
	status="ok"
	if [ "$code" -ne 0 ] || [ "$errs" -ne 0 ]; then
		status="FAILED"
		failed=$((failed + 1))
	fi
	printf "%-36s exit %-3s pass %-4s fail %-3s script-errors %-3s %s\n" "$name" "$code" "$pass" "$fail" "$errs" "$status"
done
echo "TOTAL pass $total_pass fail $total_fail suites-failed $failed"
[ "$failed" -eq 0 ]
