" File: tslint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" Version: 0.1.0
" WebPage: http://github.com/heavenshell/vim-tslint-config
" Description: Vim plugin for TSlint
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -buffer -complete=customlist,tslint#complete Tslint call tslint#setup(<q-args>, <count>, <line1>, <line2>)

command! -nargs=* -buffer -complete=customlist,tslint#complete TslintRun call tslint#run(<q-args>, <count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
