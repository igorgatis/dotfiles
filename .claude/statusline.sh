#!/usr/bin/env bash

RESET=$'\033[0m'
PATH_C=$'\033[38;5;39m'
BRANCH_C=$'\033[38;5;42m'
MODEL_C=$'\033[38;5;170m'
EFFORT_C=$'\033[38;5;214m'
TOKENS_C=$'\033[38;5;75m'
COST_C=$'\033[38;5;78m'
TIME_C=$'\033[38;5;245m'
ERR_C=$'\033[38;5;203m'

BRANCH_GLYPH="⎇"
TAU="τ"

# Maps the Claude API model id (model.id from the payload) to a short
# "Family X.Y" label. Source of truth for ids and names:
#   https://platform.claude.com/docs/en/about-claude/models/overview
# To update: add a `<id-prefix>*) echo "Family X.Y" ;;` line. Match on a
# prefix so dated, aliased, and suffixed ids (e.g. claude-opus-4-8[1m]) all
# resolve; keep the most specific prefixes first. Unknown ids fall back to
# the display name with any "(... context)" parenthetical stripped.
model_short() {
  case "$1" in
    claude-opus-4-8*)                         echo "Opus 4.8" ;;
    claude-opus-4-7*)                         echo "Opus 4.7" ;;
    claude-opus-4-6*)                         echo "Opus 4.6" ;;
    claude-opus-4-5*)                         echo "Opus 4.5" ;;
    claude-opus-4-1*)                         echo "Opus 4.1" ;;
    claude-opus-4-0*|claude-opus-4-2025*)     echo "Opus 4" ;;
    claude-sonnet-4-6*)                       echo "Sonnet 4.6" ;;
    claude-sonnet-4-5*)                       echo "Sonnet 4.5" ;;
    claude-sonnet-4-0*|claude-sonnet-4-2025*) echo "Sonnet 4" ;;
    claude-haiku-4-5*)                        echo "Haiku 4.5" ;;
    *)                                        echo "$2" ;;
  esac
}

WIDE="${TAU}${BRANCH_GLYPH}…"
dwidth() {
  local s="$1"
  local n=${#s} i=0 c w=0
  while (( i < n )); do
    c="${s:i:1}"
    case "$WIDE" in
      *"$c"*) w=$(( w + 2 )) ;;
      *)      w=$(( w + 1 )) ;;
    esac
    i=$(( i + 1 ))
  done
  printf '%s' "$w"
}

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' "${ERR_C}statusline: jq not found — install jq (brew install jq)${RESET}"
  exit 0
fi

IFS=$'\037' read -r cwd display mid effort tin tout cost dur < <(
  printf '%s' "$input" | jq -j '
    [ (.workspace.current_dir // .cwd // ""),
      (.model.display_name // "?"),
      (.model.id // ""),
      (.effort.level // ""),
      (.context_window.total_input_tokens // 0),
      (.context_window.total_output_tokens // 0),
      (.cost.total_cost_usd // 0),
      (.cost.total_duration_ms // 0)
    ] | map(tostring) | join("")'
)

home="${HOME:-$(printf '%s' ~)}"
if [[ "$cwd" == "$home" || "$cwd" == "$home"/* ]]; then
  disp="~${cwd#"$home"}"
else
  disp="$cwd"
fi

path_disp=""
IFS='/' read -ra parts <<< "$disp"
n=${#parts[@]}
for ((i = 0; i < n; i++)); do
  comp="${parts[i]}"
  if (( i == n - 1 )) || [[ -z "$comp" || "$comp" == "~" ]]; then
    :
  elif [[ "$comp" == .* ]]; then
    comp="${comp:0:2}"
  else
    comp="${comp:0:1}"
  fi
  if (( i == 0 )); then path_disp="$comp"; else path_disp="$path_disp/$comp"; fi
done

branch=$(git -C "$cwd" symbolic-ref --short -q HEAD 2>/dev/null)
[[ -z "$branch" ]] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

tin=${tin%.*}; tout=${tout%.*}; dur=${dur%.*}
tokens=$(( tin + tout ))
if (( tokens >= 1000 )); then
  tok_s=$(awk -v n="$tokens" -v t="$TAU" 'BEGIN{printf "%.1fk%s", n/1000, t}')
else
  tok_s="${tokens}${TAU}"
fi

cost_s=$(awk -v c="$cost" 'BEGIN{printf "$%.2f", c}')

total_min=$(( dur / 60000 ))
time_s=$(printf '%dh%02dm' "$(( total_min / 60 ))" "$(( total_min % 60 ))")

left_plain="$path_disp"
left="${PATH_C}${path_disp}${RESET}"
if [[ -n "$branch" ]]; then
  seg="${BRANCH_GLYPH} ${branch}"
  left_plain+=" ${seg}"
  left+=" ${BRANCH_C}${seg}${RESET}"
fi

model=$(model_short "$mid" "${display%% (*}")
ctx=""
if [[ "$display" == *"("*"context)" ]]; then
  ctx="${display##*\(}"
  ctx="${ctx%% context)}"
fi
[[ -n "$ctx" ]] && model="$model [$ctx]"
right_plain="$model"
right="${MODEL_C}${model}${RESET}"
if [[ -n "$effort" ]]; then
  right_plain+=" $effort"
  right+=" ${EFFORT_C}${effort}${RESET}"
fi
right_plain+=" $tok_s $cost_s $time_s"
right+=" ${TOKENS_C}${tok_s}${RESET} ${COST_C}${cost_s}${RESET} ${TIME_C}${time_s}${RESET}"

cols=${COLUMNS:-0}
(( cols <= 0 )) && cols=80
avail=$(( cols - ${STATUSLINE_MARGIN:-2} ))

lw=$(dwidth "$left_plain")
rw=$(dwidth "$right_plain")

if (( lw + 1 + rw > avail )); then
  keep=$(( avail - rw - 3 ))
  if (( keep > 0 )); then
    left="${PATH_C}…${left_plain: -keep}${RESET}"
  else
    left="${PATH_C}…${RESET}"
  fi
  pad=1
else
  pad=$(( avail - lw - rw ))
  (( pad < 1 )) && pad=1
fi

printf '%s%*s%s\n' "$left" "$pad" "" "$right"
