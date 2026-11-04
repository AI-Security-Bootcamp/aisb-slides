#!/usr/bin/env bash
# Build every day<N>-<topic>/main.tex in both modes and collect the PDFs in
# ./out/, named exactly as on the live site:
#
#   out/<slug>.pdf          handout      (\HANDOUT=1, \pause reveals collapsed)
#   out/<slug>-present.pdf  presentation (\HANDOUT=0, one page per reveal)
#
# LaTeX intermediates go to ./.build/<slug>-<mode>/ (kept between runs so
# rebuilds are incremental; delete it to force a clean build). Both out/ and
# .build/ are gitignored. Uses the same latexmk flags as CI.
#
# Usage:  ./build-all.sh [deck-dir ...]     (default: all decks)
#         e.g. ./build-all.sh day5-adversarial-ml
# Exit code: 0 if every build succeeded, 1 otherwise.

set -uo pipefail

WORKERS=4

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$root/out"
build="$root/.build"
mkdir -p "$out" "$build"

if [[ $# -gt 0 ]]; then
    decks=()
    for d in "$@"; do
        d="${d%/}"
        [[ -f "$root/$d/main.tex" ]] || { echo "no such deck: $d" >&2; exit 2; }
        decks+=("$root/$d/main.tex")
    done
else
    mapfile -t decks < <(find "$root" -mindepth 2 -maxdepth 2 -path "$root/day[0-9]*-*/main.tex" | sort -V)
fi
[[ ${#decks[@]} -gt 0 ]] || { echo "no decks found under day<N>-<topic>/main.tex"; exit 0; }

build_one() {  # $1 = path to main.tex, $2 = 1 (handout) or 0 (present)
    local tex="$1" handout="$2"
    local slug; slug="$(basename "$(dirname "$tex")")"
    local mode suffix
    if [[ "$handout" == 1 ]]; then mode=handout; suffix=""; else mode=present; suffix="-present"; fi
    local aux="$build/$slug-$mode"
    mkdir -p "$aux"
    if latexmk -pdf -cd -file-line-error -halt-on-error -interaction=nonstopmode \
               -usepretex="\\def\\HANDOUT{$handout}" \
               -outdir="$aux" "$tex" >"$aux/latexmk.log" 2>&1; then
        cp "$aux/main.pdf" "$out/$slug$suffix.pdf"
        printf '  [OK]   out/%s%s.pdf\n' "$slug" "$suffix"
    else
        printf '  [FAIL] %s (%s) -- log: %s\n' "$slug" "$mode" "${aux#"$root"/}/latexmk.log"
        touch "$aux/.failed"
    fi
}

echo "Building ${#decks[@]} deck(s) x 2 modes with $WORKERS parallel workers..."
jobs_=()
for tex in "${decks[@]}"; do
    for h in 1 0; do
        slug="$(basename "$(dirname "$tex")")"
        rm -f "$build/$slug-$([[ $h == 1 ]] && echo handout || echo present)/.failed"
        jobs_+=("$tex $h")
    done
done

active=0
for j in "${jobs_[@]}"; do
    build_one ${j% *} ${j##* } &
    active=$((active + 1))
    if (( active >= WORKERS )); then wait -n; active=$((active - 1)); fi
done
wait

mapfile -t failed < <(find "$build" -name .failed -printf '%h\n' | sort)
echo
if [[ ${#failed[@]} -eq 0 ]]; then
    echo "All builds succeeded. PDFs in out/:"
    ls -1 "$out"
    exit 0
fi
for d in "${failed[@]}"; do
    echo "---- ${d#"$root"/}: last 30 lines of latexmk.log ----"
    tail -n 30 "$d/latexmk.log" | sed 's/^/  /'
done
echo
echo "${#failed[@]} build(s) failed."
exit 1
