#!/bin/bash

BASE_PATH="$HOME/pythonVENVs/nerd-dictation/nerd-dictation"
NERD_DICTATION_PATH="$BASE_PATH/nerd-dictation"

declare -A LANGUAGE_MODELS
LANGUAGE_MODELS["us"]="$BASE_PATH/vosk-model-small-en-us-0.15"
LANGUAGE_MODELS["de"]="$BASE_PATH/vosk-model-small-de-0.15"
LANGUAGE_MODELS["pl"]="$BASE_PATH/vosk-model-small-pl-0.22"

source ~/pythonVENVs/nerd-dictation/bin/activate

get_current_language() {
    gsettings get org.gnome.desktop.input-sources mru-sources | grep -o "'[^']*'" | head -2 | tail -1 | tr -d "'"
}

is_dictation_running() {
    pgrep -f "$NERD_DICTATION_PATH begin" > /dev/null
    return $?
}

stop_dictation() {
    if is_dictation_running; then
        "$NERD_DICTATION_PATH" end > /dev/null
        notify-send --hint int:transient:1 "Dictation stopped"
    fi
}

start_dictation() {
    stop_dictation
    
    current_lang=$(get_current_language)
    local model_dir="${LANGUAGE_MODELS[$current_lang]}"
    export DOTOOL_XKB_LAYOUT="$current_lang"
    "$NERD_DICTATION_PATH" begin --full-sentence --punctuate-from-previous-timeout=2 --simulate-input-tool=DOTOOL --timeout=3 --numbers-as-digits --vosk-model-dir=$model_dir &
    notify-send --hint int:transient:1 "Dictation started ($current_lang)"
}

start_dictation