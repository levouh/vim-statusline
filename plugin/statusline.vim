" Verification {{{1

    if exists('g:_loaded_statusline') || v:version < 802
        finish
    endif

    let g:_loaded_statusline = 1

" Setup {{{1

    call statusline#set_hi()

" Autocommands {{{1

    augroup statusline
        au!

        " Ensure the statusline gets drawn if 'lazyredraw' is enabled
        au VimEnter * redraw

        " Update git branch information based on certain events
        au BufNewFile,BufReadPost * call statusline#git_detect(expand("<amatch>:p:h"))
        au BufEnter * call statusline#git_detect(expand("%:p:h"))

        " Reload incase syntax is reset.
        au ColorScheme * call statusline#set_hi()
    augroup END
