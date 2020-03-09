" --- Public Functions

    function! statusline#set_hi()
        " Used for statusline colors based on focused window
        hi Status1              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=7      cterm=bold
        hi Status1Insert        guifg=NONE      guibg=NONE       ctermfg=7     ctermbg=0      cterm=bold
        hi Status2              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=5      cterm=bold
        hi Status3              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=4      cterm=bold
        hi Status4              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=3      cterm=bold
        hi Status5              guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=2      cterm=bold
        hi StatusNone           guifg=NONE      guibg=NONE       ctermfg=0     ctermbg=1      cterm=bold
    endfunction

    " Set statusline based on window focus
    function! statusline#status() abort
        if !exists('g:_statusline_mode')
            call s:setup_mode_dict()
        endif

        " Determine which window is focused
        let l:focused = g:statusline_winid == win_getid(winnr())

        if mode() == 'i'
            let l:first_block = 'Status1Insert'
        else
            let l:first_block = 'Status1'
        endif

        " Setup the statusline formatting
        let l:statusline=""
        let l:statusline=focused ? "%#" . l:first_block . "#" : "%#StatusLineNC#"  " First color block
        let l:statusline.="\ %{toupper(g:_statusline_mode[mode()])}\ "             " The current mode
        let l:statusline.=focused ? "%#Status2#" : "%#StatusLineNC#"               " Second color block
        let l:statusline.="\ %<%F%m%r%h%w\ "                                       " File path, modified, readonly, helpfile, preview
        let l:statusline.=focused ? "%#Status3#" : "%#StatusLineNC#"               " Third color block
        let l:statusline.="\ %Y"                                                   " Filetype
        let l:statusline.="\ %{''.(&fenc!=''?&fenc:&enc).''}"                      " Encoding
        let l:statusline.="\ %{&ff}\ "                                             " FileFormat (dos/unix..)
        let l:statusline.=focused ? "%#Status4#" : "%#StatusLineNC#"               " Second color block
        let l:statusline.="%{statusline#git_branch_name()}"                        " Git info
        let l:statusline.=focused ? "%#Status5#" : "%#StatusNone#"                 " No color
        let l:statusline.="%="                                                     " Right Side
        let l:statusline.=focused ? "%#Status4#" : "%#StatusLineNC#"               " Third color block
        let l:statusline.="\ col:\ %02v"                                           " Colomn number
        let l:statusline.="\ ln:\ %02l/%L\ (%3p%%)\ "                              " Line number / total lines, percentage of document
        let l:statusline.=focused ? "%#Status1#" : "%#StatusLineNC#"               " First color block, see dim
        let l:statusline.="\ %n\ "                                                 " Buffer number

        return l:statusline
    endfunction

    " Detect if a directory is part of a git directory
    function! statusline#git_detect(path) abort
        unlet! b:gitbranch_path

        let b:gitbranch_pwd = expand("%:p:h")
        let l:dir = s:git_branch_dir(a:path)

        if l:dir !=# ""
            let l:path = dir . "/HEAD"

            if filereadable(l:path)
                let b:gitbranch_path = l:path
            endif
        endif
    endfunction

    " Dictionary mapping of all different modes to the text that should be displayed
    function s:setup_mode_dict()
        let g:_statusline_mode={
                            \'n' : 'Normal',
                            \'no' : 'Normal·Operator Pending',
                            \'v' : 'Visual',
                            \'V' : 'V·Line',
                            \"\<C-v>" : 'V·Block',
                            \'s' : 'Select',
                            \'S' : 'S·Line',
                            \"\<C-s>" : 'S·Block',
                            \'i' : 'Insert',
                            \'R' : 'Replace',
                            \'Rv' : 'V·Replace',
                            \'c' : 'Command',
                            \'cv' : 'Vim Ex',
                            \'ce' : 'Ex',
                            \'r' : 'Prompt',
                            \'rm' : 'More',
                            \'r?' : 'Confirm',
                            \'!' : 'Shell',
                            \'t' : 'Terminal'
                            \}
    endfunction

    " Get the name of the current git branch if it exists
    function! statusline#git_branch_name() abort
        if get(b:, "gitbranch_pwd", "") !=# expand("%:p:h") || !has_key(b:, "gitbranch_path")
            call statusline#git_detect(expand("%:p:h"))
        endif

        if has_key(b:, "gitbranch_path") && filereadable(b:gitbranch_path)
            let branch = get(readfile(b:gitbranch_path), 0, "")

            if branch =~# "^ref: "
                return " " . substitute(branch, '^ref: \%(refs/\%(heads/\|remotes/\|tags/\)\=\)\=', "", "") . " "
            elseif branch =~# '^\x\{20\}'
                return " " . branch[:6] . " "
            endif

        endif

        return ""
    endfunction

" --- Private Functions

    " Find git information based on the location of a buffer
    function! s:git_branch_dir(path) abort
        let l:path = a:path
        let l:prev = ""

        while l:path !=# prev
            let l:dir = l:path . "/.git"
            let l:type = getftype(dir)

            if l:type ==# "dir" && isdirectory(l:dir . "/objects")
                            \ && isdirectory(l:dir . "/refs")
                            \ && getfsize(l:dir . "/HEAD") > 10
                return l:dir
            elseif l:type ==# "file"
                let l:reldir = get(readfile(l:dir), 0, "")

                if l:reldir =~# "^gitdir: "
                    return simplify(l:path . "/" . l:reldir[8:])
                endif
            endif

            let l:prev = l:path
            let l:path = fnamemodify(l:path, ":h")

        endwhile

        return ""
    endfunction
