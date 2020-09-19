if has('nvim')
    if has('clipboard')
        let s:clipboard = {}
    else
        finish
    endif
else
    let s:clipboard = {}
    if exists('g:clipboard')
        let s:clipboard['copy'] = g:clipboard['copy']['+']
        let s:clipboard['paste'] = g:clipboard['paste']['+']
    elseif !has('clipboard')
        if executable('pbcopy') && executable('pbpaste')
            let s:clipboard['copy'] = 'pbcopy'
            let s:clipboard['paste'] = 'pbpaste'
        elseif exists('$DISPLAY') && executable('xsel')
            let s:clipboard['copy'] = 'xsel -ib'
            let s:clipboard['paste'] = 'xsel -ob'
        elseif exists('$DISPLAY') && executable('xclip')
            let s:clipboard['copy'] = 'xclip -i -selection clipboard'
            let s:clipboard['paste'] = 'xclip -o -selection clipboard'
        elseif exists('$TMUX') && executable('tmux')
            let s:clipboard['copy'] = 'tmux loadb -'
            let s:clipboard['paste'] = 'tmux saveb -'
        endif
    endif

    if !has('clipboard') && empty(s:clipboard)
        finish
    endif
endif

function! s:set(config)
    let s:mode = a:config[0]
    let s:op = a:config[1]
    let s:cmd = a:config[2:]
endfunction

function! s:main(type, ...)
    if empty(a:type)
        " then s:main() is called like s:main("", config, v:count1)
        call s:set(a:1)
    endif

    let previous = @"

    if s:op ==# 'p'
        if empty(s:clipboard)
            let @" = @+
        else
            let @" = system(s:clipboard['paste'])
        endif
    endif

    if s:mode ==# 'v'
        " visual mode
        exe 'normal gv' . s:cmd
    elseif s:mode ==# 'n'
        " normal mode
        if !empty(a:type)
            " see :help :map-operator
            if a:type ==# 'line'
                let _lastview = winsaveview()
                exe 'normal `[V`]' . s:cmd
                call winrestview(_lastview)
            elseif a:type ==# 'char'
                exe 'normal `[v`]' . s:cmd
            else
                " won't happen?
                exe 'normal gv' . s:cmd
            endif
        else
            " a:2 -> v:count1
            exe 'normal' a:2 . s:cmd
        endif
    else
        echoh Error | echon '->unsupported mode!' | echoh None | return
    endif

    if s:op ==# 'c'
        if empty(s:clipboard)
            let @+ = @"
        else
            let _ = system(s:clipboard['copy'], @")
        endif
    endif
    let @" = previous
endfunction

function! s:SID()
    " :help <SID>
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

function! s:map_register(config, mode)
    let mode = a:config[0]
    let cmd = a:config[2:]
    if mode ==# '!'
        let config = substitute(a:config, '^!', 'n', '')
        exe printf('nnoremap <silent> <Leader>%s ' .
                    \':call <SNR>%s_set("%s")<CR>' .
                    \':set opfunc=<SNR>%s_main<CR>g@',
                    \cmd, s:SID(), config, s:SID())
    else
        exe printf('%snoremap <silent> <Leader>%s ' .
                    \':<C-U>call <SNR>%s_main("", "%s", v:count1)<CR>',
                    \a:mode, cmd, s:SID(), a:config)
    endif
endfunction

let s:leader_clipboard_key_mapping = ['vcy', 'vcx', 'vcd', 'vpp', 'vpP',
            \'ncY', 'ncyy', 'ncx', 'ncdd', 'npp', 'npP', '!cy', '!cd']

function! s:init()
    if exists('g:leader_clipboard#key_mapping') &&
                \type(g:leader_clipboard#key_mapping) == type([])
        let config = g:leader_clipboard#key_mapping
    else
        let config = s:leader_clipboard_key_mapping
    endif
    for i in config
        let mode = i[0]
        call s:map_register(i, mode)
    endfor
endfunction

call s:init()
