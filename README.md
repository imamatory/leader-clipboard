# leader-clipboard.vim

Inspired by [christoomey/vim-system-copy](
https://github.com/christoomey/vim-system-copy),
with motion and count supported.

## Introduction
After installing this plugin, with default clipboard found (see below), you
can press `<Leader>x`, `<Leader>y`, `<Leader>p`, ... to interact with it.

The initial purpose of creating this plugin is to bring external clipboard
support to vim where `has('clipboard') == 0`, via custom key mapping. Then I
find that [neovim](https://neovim.io) has built-in support to this function.
So I modify the configuration part of this plugin to make it work for both
vim and neovim with uniform user configuration (via variable `g:clipboard`).

To neovim users, this plugin only carry key mapping with `<Leader>` to interact
with system clipboard. All key mapping, except command with `{motion}`, can be
simulated like this (and this is what I add in my `.ideavimrc`:

```
vnoremap <Leader>y "+y
vnoremap <Leader>x "+x
vnoremap <Leader>d "+d
vnoremap <Leader>p "+p
vnoremap <Leader>P "+P
nnoremap <Leader>Y "+Y
nnoremap <Leader>yy "+yy
nnoremap <Leader>x "+x
nnoremap <Leader>dd "+dd
nnoremap <Leader>p "+p
nnoremap <Leader>P "+P
```

## Installation
Any famous vim plugin manager should work.

## Note
### default clipboard
*from neovim's `:help clipboard-tool`, modified*

This plugin looks for these clipboard tools, in order of priority:

- g:clipboard

- system clipboard via register '+' if `has('clipboard') == 1`

- pbcopy/pbpaste

- xsel (if $DISPLAY is set)

- xclip (if $DISPLAY is set)

- tmux (if $TMUX is set)

### If no clipboard found
This plugin would do nothing; no keyboard remapping happens.

## Configuration

```vim
"
" set copy / paste command
"

" from neovim `:help g:clipboard`, modified
" To configure a custom clipboard tool, set `g:clipboard` to a dictionary:
let g:clipboard = {
\   'copy': {
\      '+': 'tmux load-buffer -',
\      '*': 'tmux load-buffer -',
\    },
\   'paste': {
\      '+': 'tmux save-buffer -',
\      '*': 'tmux save-buffer -',
\   },
\ }

"
" define key mapping
"

" this variable is a list containing strings;
" each string is constructed in this way:
" 1st char: mapping mode, 'n' for normal mode; 'v' for visual mode,
" and '!' for command with motion, like "d", "y".
" 2nd char: op mode, 'c' for copy to clipboard; 'p' for paste from clipboard
" following char(s): command to map, like 'p', 'P', 'yy', 'Y', 'x', 'dd' etc.
"
" default binding
"let s:leader_clipboard_key_mapping = ['vcy', 'vcx', 'vcd', 'vpp', 'vpP',
"            \'ncY', 'ncyy', 'ncx', 'ncdd', 'npp', 'npP', '!cy', '!cd']

" customize (add it to your $VIMRC)
let g:leader_clipboard#key_mapping = [] " disable binding
let g:leader_clipboard#key_mapping = ['vcy', 'npp'] " or only enable part of it
```
