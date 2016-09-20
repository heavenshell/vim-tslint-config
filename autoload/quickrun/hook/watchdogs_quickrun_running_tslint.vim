let s:save_cpo = &cpo
set cpo&vim

let s:hook = {
\ 'config' : {
\   'enable' : 0
\ },
\}

let s:tslint = {}

function! s:hook.init(...)
  if self.config.enable
    let s:tslint = tslint#init()
    let g:watchdogs_quickrun_running_check = 1
  endif
endfunction

function! s:hook.on_exit(...)
  let g:watchdogs_quickrun_running_check = 0
endfunction

function! quickrun#hook#watchdogs_quickrun_running_tslint#new()
  return deepcopy(s:hook)
endfunction

function! s:hook.on_module_loaded(session, context)
  let a:session['config']['command'] = s:tslint['bin']
  let a:session['config']['cmdopt'] = s:tslint['config']
  "let a:session['config']['exec'] = ['%c %o %s']
  let a:session['config']['exec'] = ['%c %s:p']
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
