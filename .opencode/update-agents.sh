#!/usr/bin/env bash
# update-agents.sh - Download/update agentic template files from GitHub
#
# Downloads AGENTS.md, opencode.json, and all files under .opencode/ (and
# the legacy agents/ path) from https://github.com/aheimsbakk/agentic-template
# into the current directory or a specified target directory.

set -euo pipefail

# ─── Constants ────────────────────────────────────────────────────────────────

readonly REPO="aheimsbakk/agentic-template"
readonly GITHUB_RAW="https://raw.githubusercontent.com/${REPO}"
readonly GITHUB_API="https://api.github.com/repos/${REPO}"
readonly VERSION="1.1.0"
readonly SCRIPT_NAME="$(basename "$0")"

# ─── Helpers ──────────────────────────────────────────────────────────────────

usage() {
	cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] [BRANCH/TAG]

Download and update agentic template files from GitHub into the current
directory or a specified target directory.

    Files downloaded:
  AGENTS.md
  .opencode/  (all files, recursively)  # previously 'agents/'

Arguments:
  BRANCH/TAG    Branch or tag to download from (default: main)

Options:
  -d DIR        Target directory (default: current directory)
  -h, --help    Show this help message and exit
  -v, --version Show version and exit

Examples:
  ${SCRIPT_NAME}                     # Download from main into current dir
  ${SCRIPT_NAME} develop             # Download from the 'develop' branch
  ${SCRIPT_NAME} v1.2.0              # Download from the 'v1.2.0' tag
  ${SCRIPT_NAME} -d ~/myproject      # Download into ~/myproject
  ${SCRIPT_NAME} -d ~/myproject main # Download from main into ~/myproject
EOF
}

version() {
	echo "${SCRIPT_NAME} ${VERSION}"
}

die() {
	echo "error: $*" >&2
	exit 1
}

# Check that required tools are available
check_deps() {
	local missing=()
	for cmd in curl python3; do
		command -v "$cmd" &>/dev/null || missing+=("$cmd")
	done
	if [[ ${#missing[@]} -gt 0 ]]; then
		die "missing required tools: ${missing[*]}"
	fi
}

# ─── Core logic ───────────────────────────────────────────────────────────────

# Fetch file list for agents/ from the GitHub API tree for the given ref
get_agent_files() {
	local ref="$1"
	local url="${GITHUB_API}/git/trees/${ref}?recursive=1"
	local response

	response=$(curl -fsSL "$url" 2>/dev/null) ||
		die "failed to fetch file list from GitHub (branch/tag '${ref}' may not exist)"

	# Extract blob paths that start with .opencode/ or the legacy agents/
	python3 -c "
import sys, json
data = json.loads('''${response}''')
for item in data.get('tree', []):
    if item['type'] == 'blob':
        p = item.get('path','')
        if p.startswith('.opencode/') or p == '.opencode' or p.startswith('agents/'):
            print(p)
"
}

# Download a single file from the raw GitHub URL, replacing only if different
download_file() {
	local ref="$1"
	local remote_path="$2"
	local target_dir="$3"
	local dest="${target_dir}/${remote_path}"
	local dest_parent
	dest_parent="$(dirname "$dest")"
	local url="${GITHUB_RAW}/${ref}/${remote_path}"
	local tmp

	tmp=$(mktemp) || die "failed to create temp file"
	# shellcheck disable=SC2064
	trap "rm -f '${tmp}'" RETURN

	if ! curl -fsSL -o "$tmp" "$url" 2>/dev/null; then
		echo "  FAIL   ${remote_path}"
		rm -f "$tmp"
		return 1
	fi

	if [[ ! -d "$dest_parent" ]]; then
		mkdir -p "$dest_parent"
	fi

	if [[ -f "$dest" ]] && cmp -s "$tmp" "$dest"; then
		echo "  OK     ${remote_path}"
	else
		cp "$tmp" "$dest"
		echo "  UPDATED ${remote_path}"
	fi
}

# ─── Argument parsing ─────────────────────────────────────────────────────────

TARGET_DIR="."
REF="main"

while [[ $# -gt 0 ]]; do
	case "$1" in
	-h | --help)
		usage
		exit 0
		;;
	-v | --version)
		version
		exit 0
		;;
	-d)
		[[ $# -gt 1 ]] || die "option -d requires an argument"
		TARGET_DIR="$2"
		shift 2
		;;
	-d*)
		TARGET_DIR="${1#-d}"
		shift
		;;
	-*)
		die "unknown option: $1 (try --help)"
		;;
	*)
		REF="$1"
		shift
		;;
	esac
done

# ─── Main ─────────────────────────────────────────────────────────────────────

check_deps

# Resolve target directory to an absolute path
TARGET_DIR="$(realpath -m "$TARGET_DIR")"

if [[ ! -d "$TARGET_DIR" ]]; then
	die "target directory does not exist: ${TARGET_DIR}"
fi

echo "Repository : ${REPO}"
echo "Branch/tag : ${REF}"
echo "Target dir : ${TARGET_DIR}"
echo ""

# Static top-level files
STATIC_FILES=(
	"AGENTS.md"
)

# Dynamic: discover all files under .opencode/ (also accepts legacy agents/)
mapfile -t AGENT_FILES < <(get_agent_files "$REF")

ALL_FILES=("${STATIC_FILES[@]}" "${AGENT_FILES[@]}")

# If .opencode/.gitignore exists in the target dir, parse ignore patterns
IGNORE_PATTERNS=()
IGNORE_DIRS=()
GITIGNORE_FILE="${TARGET_DIR}/.opencode/.gitignore"
if [[ -f "$GITIGNORE_FILE" ]]; then
	while IFS= read -r line || [[ -n "$line" ]]; do
		# Strip comments and surrounding whitespace
		line="${line%%#*}"
		line="$(echo "$line" | sed -e 's/^\s*//' -e 's/\s*$//')"
		[[ -z "$line" ]] && continue

		# Normalize: remove leading ./ or leading / (we work relative to .opencode)
		norm="$line"
		norm="${norm#./}"
		norm="${norm#/}"

		IGNORE_PATTERNS+=("$norm")

		# Determine if this pattern should be treated as a directory ignore.
		# If pattern ends with a slash it's a dir; otherwise if the path exists
		# locally under .opencode and is a directory treat it as a dir too.
		if [[ "$norm" == */ ]]; then
			d="${norm%/}"
			IGNORE_DIRS+=("$d")
		else
			# If the exact path exists locally and is a directory, mark as dir
			if [[ -d "${TARGET_DIR}/.opencode/${norm}" ]]; then
				IGNORE_DIRS+=("$norm")
			fi
		fi
	done <"$GITIGNORE_FILE"
fi

# Helper: return 0 if a path (remote-style, e.g. .opencode/foo) matches any ignore pattern
matches_ignore() {
	local path="$1" # e.g. .opencode/foo/bar
	[[ ${#IGNORE_PATTERNS[@]} -eq 0 ]] && return 1

	local p norm
	for p in "${IGNORE_PATTERNS[@]}"; do
		norm="$p"
		# If pattern contains wildcards, match using shell pattern against the path
		if [[ "$norm" == *"*"* || "$norm" == *"?"* || "$norm" == *"["* ]]; then
			# prefix with .opencode/ if pattern is not anchored
			if [[ "$norm" != /* ]]; then
				if [[ "$path" == .opencode/${norm} || "$path" == .opencode/${norm}* ]]; then
					return 0
				fi
			else
				if [[ "$path" == $norm ]]; then
					return 0
				fi
			fi
			continue
		fi

		# Exact file match
		if [[ "$path" == ".opencode/${norm}" ]]; then
			return 0
		fi
		# If this pattern is known to be a directory ignore, match prefix
		for d in "${IGNORE_DIRS[@]}"; do
			if [[ "$path" == .opencode/${d}* ]]; then
				return 0
			fi
		done
	done
	return 1
}

fail_count=0
for file in "${ALL_FILES[@]}"; do
	# If file is under .opencode and matches ignore patterns, skip downloading
	if [[ "$file" == .opencode/* ]] && matches_ignore "$file"; then
		echo "  SKIP   ${file} (ignored by .opencode/.gitignore)"
		continue
	fi
	download_file "$REF" "$file" "$TARGET_DIR" || ((fail_count++)) || true
done

# Remove local files that no longer exist in the remote
# Build a lookup set of all remote paths
declare -A remote_set
for file in "${ALL_FILES[@]}"; do
	remote_set["$file"]=1
done

# Walk managed locations: top-level static files + the .opencode/ (or agents/) subtree
while IFS= read -r -d '' local_file; do
	rel="${local_file#"${TARGET_DIR}/"}"
	if [[ -z "${remote_set[$rel]+_}" ]]; then
		# If under .opencode and matches ignore patterns, do not remove
		if [[ "$rel" == .opencode/* ]] && matches_ignore "$rel"; then
			echo "  KEEP    ${rel} (ignored by .opencode/.gitignore)"
			continue
		fi
		rm -f "$local_file"
		echo "  DELETED ${rel}"
		# Remove empty parent directories inside agents/
		rmdir --ignore-fail-on-non-empty -p "$(dirname "$local_file")" 2>/dev/null || true
	fi
done < <(
	# Enumerate local candidates: static files + everything under agents/
	for f in "${STATIC_FILES[@]}"; do
		[[ -f "${TARGET_DIR}/${f}" ]] && printf '%s\0' "${TARGET_DIR}/${f}"
	done
	# prefer .opencode directory, fall back to legacy agents/
	if [[ -d "${TARGET_DIR}/.opencode" ]]; then
		# Build find expression that prunes ignored directories so we don't traverse them
		if [[ ${#IGNORE_DIRS[@]} -gt 0 ]]; then
			# Construct -path ... -prune -o clauses
			expr=()
			for d in "${IGNORE_DIRS[@]}"; do
				# escape for find: prefix path
				expr+=(-path "${TARGET_DIR}/.opencode/${d}" -prune -o)
			done
			# final action: print files
			# shellcheck disable=SC2086
			find "${TARGET_DIR}/.opencode" ${expr[@]} -type f -print0
		else
			find "${TARGET_DIR}/.opencode" -type f -print0
		fi
	elif [[ -d "${TARGET_DIR}/agents" ]]; then
		find "${TARGET_DIR}/agents" -type f -print0
	fi
)

echo ""
if [[ $fail_count -gt 0 ]]; then
	echo "Done with ${fail_count} error(s)."
	exit 1
else
	echo "Done."
fi
