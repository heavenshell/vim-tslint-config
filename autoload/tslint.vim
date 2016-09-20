" File: tslint.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" Version: 0.1.0
" WebPage: http://github.com/heavenshell/vim-tslint-config
" Description: Vim plugin for tslint
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim
if exists('g:tslint_loaded')
  finish
endif
let g:tslint_loaded = 1

if !exists('g:tslint_configs')
  let g:tslint_configs = []
endif

let s:tslint_config = ''

let s:tslint_complete = ['c']

let s:tslint = {}

function! s:detect_tslint_bin(srcpath) abort
  if executable('tslint') == 0
    let root_path = finddir('node_modules', a:srcpath . ';')
    let tslint = root_path . '/.bin/tslint'
  endif

  return tslint
endfunction

function! s:build_config(srcpath) abort
  let root_path = finddir('node_modules', a:srcpath . ';')
  if s:tslint_config == '' && len(g:tslint_configs) > 0
    for c in g:tslint_configs
      let path = printf('%s/%s', root_path, c)
      if isdirectory(path)
        let s:tslint_config = path
      else
        let s:tslint_config = printf('%s', findfile(c, a:srcpath . ';'))
      endif
    endfor
  else
    " If -c config path is set.
    let path = printf('%s/%s', root_path, s:tslint_config)
    if isdirectory(path)
      let s:tslint_config = path
    else
      let s:tslint_config = printf('%s/%s', fnamemodify(root_path, ':h:p'), s:tslint_config)
    endif
  endif
  if s:tslint_config == ''
    let config_path = printf(' -f compact ')
  else
    let config_path = printf(' --config=%s ', s:tslint_config)
  endif
  return config_path
endfunction

" Build tslint bin path.
function! s:build_tslint(binpath, configpath, target) abort
  let cmd = a:binpath . a:configpath . '%'
  return cmd
endfunction

function! s:parse_options(args) abort
  if a:args =~ '-c\s'
    let args = split(a:args, '-c\s')
    if len(args) > 0
      let s:tslint_config = matchstr(args[0],'^\s*\zs.\{-}\ze\s*$')
    endif
  endif
endfunction

" Build tslint cmmand {name,value} complete.
function! tslint#complete(lead, cmd, pos) abort
  let cmd = split(a:cmd)
  let size = len(cmd)
  if size <= 1
    " Command line name completion.
    let args = map(copy(s:tslint_complete), '"-" . v:val . " "')
    return filter(args, 'v:val =~# "^".a:lead')
  endif
  " Command line value completion.
  let name = cmd[1]
  let filter_cmd = printf('v:val =~ "^%s"', a:lead)

  return filter(g:tslint_configs, filter_cmd)
endfunction

" Detect tslint bin and config file.
function! tslint#init() abort
  let tslint = s:detect_tslint_bin(expand('%:p'))
  let config = s:build_config(expand('%:p'))

  let s:tslint['bin'] = tslint
  let s:tslint['config'] = config

  return s:tslint
endfunction

" Setup tslint settings.
function! tslint#setup(...)
  call s:parse_options(a:000[0])
  let ret = tslint#init()
  let tslint = ret['bin']
  let config = ret['config']

  let tslint_path = s:build_tslint(tslint, config, expand('%:p'))
  let cmd = substitute(tslint_path, '\s', '\\ ', 'g')
  "let &makeprg did not work properly.
  execute 'set makeprg=' . cmd

  " Errorformat for `tslint`.
  let fmt = '%f[%l\\,\ %c]:\ %m'

  let &errorformat = fmt
endfunction

function! tslint#run(...) abort
  call tslint#setup(a:000[0])
  execute 'WatchdogsRun'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
