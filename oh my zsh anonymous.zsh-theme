#
# Oh My Zsh Theme: anonymous
#
# =========================================================
# 1. Colors Setup (Customize these variables easily)
# =========================================================

# Zsh Escape Codes:
# %F{...} : Start foreground color
# %f      : End foreground color
# %B      : Start bold
# %b      : End bold

# Structure
SEP_COLOR="%F{237}"         # Light Grey/White-like for separator
PROMPT_CHAR_COLOR="%F{red}" # Color for the '❯' command prompt

# Data
TIME_COLOR="%F{blue}"
USER_COLOR="%F{green}"
PWD_COLOR="%F{yellow}"
GIT_COLOR="%F{magenta}"

SEP_START="*"
SEP_END="*"
SEP="*"

# =========================================================
# 2. Git Status Function (Returns formatted string or nothing)
# =========================================================

function custom_git_status() {
  # Check if we are inside a git repository
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    # Get the current branch name
    local branch_name
    branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    # Check for uncommitted changes ('!' for dirty repo)
    local dirty_symbol=""
    if ! git diff --quiet --exit-code --ignore-submodules --no-ext-diff; then
      dirty_symbol="!"
    fi
    
    # Return the formatted string: [GIT_BRANCH!] 
    echo "${SEP_COLOR} - ${GIT_COLOR}${branch_name}${dirty_symbol}]%f"
  else
    echo "${USER_COLOR}]"
  fi
}



# =========================================================
# 3. Terminal Resize Control
# =========================================================

# Global variable to hold the pre-calculated separator line string.
# This must be defined globally so TRAPWINCH can update it.
SEP_LINE_VAR="" 

# Function to calculate the working separator line based on current width.
# Note: This is now a standalone function definition.
function calculate_separator_line() {
  # YOUR CONFIRMED WORKING LINE, now captured into a variable.
  SEP_LINE_VAR="${PROMPT_CHAR_COLOR}${SEP_START}${SEP_COLOR}$(/usr/bin/printf '%.s'${SEP}'' $(/usr/bin/seq 3 $(tput cols)))${PROMPT_CHAR_COLOR}${SEP_END}%f"
}

# Special Zsh function called when the window is resized (SIGWINCH).
# This is the hook that ensures the prompt redraws with the new width.
function TRAPWINCH() {
  # 1. Recalculate the line width
  calculate_separator_line
  # 2. Force Zsh to redraw the prompt immediately
  # This makes the change instant, without needing to press Enter.
  zle && zle reset-prompt
}

# Execute this once when the theme loads to set the initial width.
# This ensures the separator line exists before the first prompt.
calculate_separator_line

# =========================================================
# 4. Prompt Variable Definition
# =========================================================

# Clear PROMPT/RPROMPT to start fresh
PROMPT=""
RPROMPT=""

# --- Line 1: Separator Line (Dotted Underline Simulation) ---
    NEWLINE=$'\n'
    PROMPT+="${SEP_LINE_VAR}${NEWLINE}"

# --- Line 2: The Core Information Line ---
# Original format requested: [time in 12hr] [username {git ? "- git branch"}] [pwd with ~] [points]
# Replicating your new format: [%n@%m] [%t] [%w %~]
# Combining with Git: [%t] [%n] [GIT] [%w] 
# NOTE: The %t (24h) and %T (12h) codes are different. Using %T for 12hr AM/PM.

# [Time: 12hr AM/PM]
PROMPT+="${TIME_COLOR}[%D{%d-%m-%Y\ %I:%M%p}]" 

# [Username]
PROMPT+=" ${USER_COLOR}[%n@%m%f" 

# [Git Branch] - **This is the main integration point**
PROMPT+="\$(custom_git_status)" 

# [Current Directory: Full Path (%w) and Home Abbreviated (%~)]
# The original code had both %w and %~, which can be redundant.
# Using only %~ (home abbreviation) for cleanliness.
PROMPT+=" ${PWD_COLOR}[%~]%f"           

# [Points: Zsh Prompt Char]
# PROMPT+=" ${SEP_COLOR}[%#]%f"         

# --- Line 3: The Command Input Line ---
PROMPT+=$NEWLINE
PROMPT+="${PROMPT_CHAR_COLOR}❯ %f"    # -> command prompt symbol
