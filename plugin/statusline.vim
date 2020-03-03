" --- Verification

    if exists('g:_loaded_statusline') || v:version < 802
        finish
    endif

    let g:_loaded_statusline = 1

" --- Highlight Groups

    " Used for statusline colors based on focused window
    hi Status1              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=7      cterm=bold
    hi Status1Insert        guifg=NONE      guibg=NONE       ctermfg=7     ctermbg=0      cterm=bold
    hi Status2              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=5      cterm=bold
    hi Status3              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=4      cterm=bold
    hi Status4              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=3      cterm=bold
    hi Status5              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=2      cterm=bold
    hi StatusNone           guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=1      cterm=bold

" --- Autocommands

    augroup statusline
        au!

        " Ensure the statusline gets drawn if 'lazyredraw' is enabled
        au VimEnter * redraw

        " Update git branch information based on certain events
        au BufNewFile,BufReadPost * call statusline#git_detect(expand("<amatch>:p:h"))
        au BufEnter * call statusline#git_detect(expand("%:p:h"))
    augroup END
