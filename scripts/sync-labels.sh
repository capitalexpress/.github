#!/usr/bin/env bash
# Creates or updates the labels in labels.yml on capitalexpress repos. Additive and
# idempotent: labels not in the file are left alone.
#
# Usage: scripts/sync-labels.sh [--dry-run] [--all | <repo>...]
#   <repo>     owner/name or just name (capitalexpress/ is assumed)
#   --all      every non-archived repo in the capitalexpress org
#   --dry-run  print what would change, change nothing
# Needs gh authenticated with issues:write on the target repos.

set -euo pipefail

readonly ORG="capitalexpress"
LABELS_FILE="$(dirname "$0")/../labels.yml"
readonly LABELS_FILE

dry_run=false
repos=()
for arg in "$@"; do
	case "$arg" in
	--dry-run) dry_run=true ;;
	--all) mapfile -t repos < <(gh repo list "$ORG" --no-archived --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner') ;;
	-h | --help)
		sed -n '2,9p' "$0"
		exit 0
		;;
	*/*) repos+=("$arg") ;;
	*) repos+=("$ORG/$arg") ;;
	esac
done
if ((${#repos[@]} == 0)); then
	echo "usage: $0 [--dry-run] [--all | <repo>...]" >&2
	exit 2
fi

# Parse labels.yml into parallel arrays (strict format, see the file's header).
names=()
colors=()
descriptions=()
value() { sed -E 's/^[[:space:]-]*[a-z]+:[[:space:]]*"(.*)"[[:space:]]*$/\1/' <<<"$1"; }
while IFS= read -r line; do
	case "$line" in
	"- name:"*) names+=("$(value "$line")") ;;
	"  color:"*) colors+=("$(value "$line")") ;;
	"  description:"*) descriptions+=("$(value "$line")") ;;
	esac
done <"$LABELS_FILE"
if ((${#names[@]} == 0 || ${#names[@]} != ${#colors[@]} || ${#names[@]} != ${#descriptions[@]})); then
	echo "sync-labels: $LABELS_FILE is malformed (${#names[@]} names, ${#colors[@]} colors, ${#descriptions[@]} descriptions)" >&2
	exit 1
fi

failed=0
for repo in "${repos[@]}"; do
	current="$(gh label list -R "$repo" --limit 1000 --json name,color,description \
		--jq '.[] | "\(.name)\t\(.color | ascii_upcase)\t\(.description)"')" || {
		echo "✗ $repo: can't read labels" >&2
		failed=1
		continue
	}
	changes=0
	for i in "${!names[@]}"; do
		wanted="${names[$i]}"$'\t'"${colors[$i]^^}"$'\t'"${descriptions[$i]}"
		grep -qxF -- "$wanted" <<<"$current" && continue
		changes=$((changes + 1))
		if $dry_run; then
			echo "  $repo: would set '${names[$i]}'"
		elif ! gh label create "${names[$i]}" -R "$repo" --color "${colors[$i]}" \
			--description "${descriptions[$i]}" --force >/dev/null; then
			echo "✗ $repo: failed to set '${names[$i]}'" >&2
			failed=1
		fi
	done
	echo "✓ $repo: $changes label(s) $($dry_run && echo "to change" || echo "changed")"
done
exit "$failed"
