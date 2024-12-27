#!/usr/bin/env bash

THEME_SHOW_USER_HOST=true
USER_HOST_THEME_PROMPT_SUFFIX=':'
VIRTUALENV_THEME_PROMPT_PREFIX=''
SCM_THEME_PROMPT_DIRTY=${SCM_THEME_PROMPT_DIRTY:1}
SCM_THEME_PROMPT_CLEAN=${SCM_THEME_PROMPT_CLEAN:1}
SCM_THEME_PROMPT_PREFIX=''
SCM_THEME_PROMPT_SUFFIX=''
SCM_GIT_SHOW_MINIMAL_INFO=true

function user_mark() {
    case $(id -u) in
        0) echo "#"
            ;;
        *) echo "\$"
            ;;
    esac
}

function prompt_command() {
	PS1="${bold_green}$(virtualenv_prompt)$(user_host_prompt)${reset_color}${bold_white}\w${reset_color}$(scm_prompt_char_info)${bold_blue}$(user_mark)${blue}${reset_color} ";
}

safe_append_prompt_command prompt_command
