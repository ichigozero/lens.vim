" Copyright (c) 2020 Spiers, Cam <camspiers@gmail.com>
" Licensed under the terms of the MIT license.

""
" ██╗     ███████╗███╗   ██╗███████╗  ██╗   ██╗██╗███╗   ███╗
" ██║     ██╔════╝████╗  ██║██╔════╝  ██║   ██║██║████╗ ████║
" ██║     █████╗  ██╔██╗ ██║███████╗  ██║   ██║██║██╔████╔██║
" ██║     ██╔══╝  ██║╚██╗██║╚════██║  ╚██╗ ██╔╝██║██║╚██╔╝██║
" ███████╗███████╗██║ ╚████║███████║██╗╚████╔╝ ██║██║ ╚═╝ ██║
" ╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═══╝  ╚═╝╚═╝     ╚═╝


if exists('g:lens#loaded')
  finish
endif

let g:lens#loaded = 1
let golden_ratio = 1.618

if ! exists('g:lens#disabled')
  " Global disable
  let g:lens#disabled = 0
endif

if ! exists("g:lens#resize_floating")
  " Enable resizing of neovim's floating windows
  let g:lens#resize_floating = 0
endif

if ! exists('g:lens#height_resize_max')
  " When resizing don't go beyond the following height
  let g:lens#height_resize_max = float2nr((&lines / golden_ratio))
endif

if ! exists('g:lens#height_resize_min')
  " When resizing don't go below the following height
  let g:lens#height_resize_min = float2nr(
    \ (&lines / golden_ratio) / ( 3 * golden_ratio)
  \)
endif

if ! exists('g:lens#width_resize_max')
  " When resizing don't go beyond the following width
  let g:lens#width_resize_max = float2nr((&columns / golden_ratio))
endif

if ! exists('g:lens#width_resize_min')
  " When resizing don't go below the following width
  let g:lens#width_resize_min = float2nr(
    \ (&columns / golden_ratio) / ( 3 * golden_ratio)
  \)
endif

if ! exists("g:lens#target_width_padding")
  let g:lens#target_width_padding = 5
endif

if ! exists('g:lens#disabled_filetypes')
  " Disable for the following filetypes
  let g:lens#disabled_filetypes = []
endif

if ! exists('g:lens#disabled_buftypes')
  " Disable for the following buftypes
  let g:lens#disabled_buftypes = []
endif

if ! exists('g:lens#disabled_filenames')
  " Disable for the following filenames
  let g:lens#disabled_filenames = []
endif

if ! exists('g:lens#disable_for_diff')
  " Disable for the following filenames
  let g:lens#disable_for_diff = 0
endif


""
" Toggles the plugin on and off
function! lens#toggle() abort
  let g:lens#disabled = !g:lens#disabled
endfunction

""
" Returns a width or height respecting the passed configuration
function! lens#get_size(current, target, resize_min, resize_max) abort
  return max([
    \ a:current,
    \ min([
      \ max([a:target, a:resize_min]),
      \ a:resize_max,
    \ ])
  \ ])
endfunction

""
" Gets the rows of the current window
function! lens#get_rows() abort
  return line('$')
endfunction

""
" Gets the target height
function! lens#get_target_height() abort
  return lens#get_rows() + (&laststatus != 0 ? 1 : 0)
endfunction

""
" Gets the cols of the current window
function! lens#get_cols() abort
  return max(map(getline(line("w0"),line("w$")), {k,v->len(v)}))
endfunction

""
" Gets the target width
function! lens#get_target_width() abort
  return lens#get_cols()
    \ + (wincol()
    \ - virtcol('.'))
    \ + g:lens#target_width_padding
endfunction

""
" Resizes the window to respect minimal lens configuration
function! lens#run() abort
  let width = lens#get_size(
    \ winwidth(0),
    \ lens#get_target_width(),
    \ g:lens#width_resize_min,
    \ g:lens#width_resize_max
  \)

  let height = lens#get_size(
    \ winheight(0),
    \ lens#get_target_height(),
    \ g:lens#height_resize_min,
    \ g:lens#height_resize_max
  \)

  execute 'vertical resize ' . width
  execute 'resize ' . height
endfunction

function! lens#win_enter() abort
  " Don't resize if the window is floating
  if exists('*nvim_win_get_config')
    if ! g:lens#resize_floating && nvim_win_get_config(0)['relative'] != ''
      return
    endif
  endif

  if g:lens#disabled
    return
  endif

  if index(g:lens#disabled_filetypes, &filetype) != -1
    return
  endif

  if index(g:lens#disabled_buftypes, &buftype) != -1
      return
  endif

  if len(g:lens#disabled_filenames) > 0
      let l:filename = expand('%:p')
      for l:pattern in g:lens#disabled_filenames
          if match(l:filename, l:pattern) > -1
              return
          endif
      endfor
  endif

  if g:lens#disable_for_diff == 1
    if &diff == 1
      return
    endif
  endif

  call lens#run()
endfunction

""
" Resize on window enter
augroup lens
  autocmd! WinEnter * call lens#win_enter()
augroup END

" vim:fdm=marker
