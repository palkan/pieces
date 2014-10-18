'use strict'
pi = require '../core'
require '../components'
utils = pi.utils

#####
pi.Guesser.rules_for 'list', ['pi-list'], ['ul'], 
  (nod) -> 
    nod.children('ul').length is 1

#####
pi.Guesser.rules_for 'text_input', ['pi-text-input-wrap'], ['input[text]']

#####
pi.Guesser.rules_for 'form', ['pi-form'], ['form']

#####
pi.Guesser.rules_for 'action_list', ['pi-action-list']  

#####
pi.Guesser.rules_for 'checkbox', ['pi-checkbox-wrap'], null

#####
pi.Guesser.rules_for 'file_input', ['pi-file-input-wrap'], ['input[file]'], (nod) -> nod.children("input[type=file]").length is 1

#####
pi.Guesser.rules_for 'popup_container', ['pi-popup']

#####
pi.Guesser.rules_for 'progress_bar',['pi-progressbar']

#####
pi.Guesser.rules_for 'radio_group', ['pi-radio-group']

#####
pi.Guesser.rules_for 'search_input', ['pi-search-field']

#####
pi.Guesser.rules_for 'select_input', ['pi-select-field'], null

#####
pi.Guesser.rules_for 'sorters', ['pi-sorters'], null

#####
pi.Guesser.rules_for 'text_area', ['pi-textarea'], ['textarea']

#####
pi.Guesser.rules_for 'toggle_button', ['pi-toggle-button']