" Globals {{{1

    let s:palette = {}

    let s:palette.black        = [235, '#1C1C1C']

    let s:palette.color00      = [235, '#555555']
    let s:palette.color01      = [235, '#696969']
    let s:palette.color02      = [238, '#7E7E7E']
    let s:palette.color03      = [239, '#949494']
    let s:palette.color04      = [240, '#AAAAAA']
    let s:palette.color05      = [242, '#C1C1C1']
    let s:palette.color06      = [243, '#D8D8D8']
    let s:palette.color07      = [244, '#F0F0F0']

" Public Functions {{{1

    fu! statusline#set_hi() " {{{2
        " Used for statusline colors based on focused window
        call s:hi('Status1', s:palette.black, s:palette.color07, 'bold')
        call s:hi('Status2', s:palette.black, s:palette.color05, 'bold')
        call s:hi('Status3', s:palette.black, s:palette.color03, 'bold')
        call s:hi('Status4', s:palette.black, s:palette.color01, 'bold')
        call s:hi('Status5', s:palette.black, s:palette.color00, 'bold')

        call s:hi('StatusInsert', s:palette.color07, s:palette.black, 'bold')
        call s:hi('StatusNone', s:palette.color07, s:palette.black, 'bold')
    endfu

    fu! statusline#status() abort " {{{2
        " Set statusline based on window focus
        if !exists('g:_statusline_mode')
            call s:setup_mode_dict()
        endif

        " Determine which window is focused
        let focused = g:statusline_winid == win_getid(winnr())

        if mode() =~ '[i|t]'
            let first_block = 'StatusInsert'
        else
            let first_block = 'Status1'
        endif

        " Setup the statusline formatting
        let statusline=""
        let statusline=focused ? "%#" . first_block . "#" : "%#StatusNone#"      " First color block
        let statusline.="\ %{toupper(g:_statusline_mode[mode()])}\ "             " The current mode
        let statusline.=focused ? "%#Status2#" : "%#StatusNone#"                 " Second color block
        let statusline.="\ %<%F%m%r%h%w\ "                                       " File path, modified, readonly, helpfile, preview
        let statusline.=focused ? "%#Status3#" : "%#StatusNone#"                 " Third color block
        let statusline.="\ %Y"                                                   " Filetype
        let statusline.="\ %{''.(&fenc!=''?&fenc:&enc).''}"                      " Encoding
        let statusline.="\ %{&ff}\ "                                             " FileFormat (dos/unix..)
        let statusline.=focused ? "%#Status4#" : "%#StatusNone#"                 " Second color block
        let statusline.="%{statusline#git_branch_name()}"                        " Git info
        let statusline.=focused ? "%#Status5#" : "%#StatusNone#"                 " No color
        let statusline.="%="                                                     " Right Side
        let statusline.=focused ? "%#Status4#" : "%#StatusNone#"                 " Third color block
        let statusline.="\ col:\ %02v"                                           " Colomn number
        let statusline.="\ ln:\ %02l/%L\ (%3p%%)\ "                              " Line number / total lines, percentage of document
        let statusline.=focused ? "%#Status1#" : "%#StatusNone#"                 " First color block, see dim
        let statusline.="\ %n\ "                                                 " Buffer number

        return statusline
    endfu

    " Detect if a directory is part of a git directory
    fu! statusline#git_detect(path) abort " {{{2
        unlet! b:gitbranch_path

        let b:gitbranch_pwd = expand("%:p:h")
        let dir = s:git_branch_dir(a:path)

        if dir !=# ""
            let path = dir . "/HEAD"

            if filereadable(path)
                let b:gitbranch_path = path
            endif
        endif
    endfu

    " Dictionary mapping of all different modes to the text that should be displayed
    fu s:setup_mode_dict()
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
    endfu

    " Get the name of the current git branch if it exists
    fu! statusline#git_branch_name() abort " {{{2
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
    endfu

" Private Functions {{{1

    fu! s:git_branch_dir(path) abort " {{{2
        " Find git information based on the location of a buffer
        let path = a:path
        let prev = ""

        while path !=# prev
            let dir = path . "/.git"
            let type = getftype(dir)

            if type ==# "dir" && isdirectory(dir . "/objects")
                            \ && isdirectory(dir . "/refs")
                            \ && getfsize(dir . "/HEAD") > 10
                return dir
            elseif type ==# "file"
                let reldir = get(readfile(dir), 0, "")

                if reldir =~# "^gitdir: "
                    return simplify(path . "/" . reldir[8:])
                endif
            endif

            let prev = path
            let path = fnamemodify(path, ":h")

        endwhile

        return ""
    endfu

    fu! s:hi(group, fg_color, bg_color, style) " {{{2
        let highlight_command = ['hi', a:group]

        if !empty(a:fg_color)
            let [ctermfg, guifg] = a:fg_color
            call add(highlight_command, printf('ctermfg=%d guifg=%s', ctermfg, guifg))
        endif

        if !empty(a:bg_color)
            let [ctermbg, guibg] = a:bg_color
            call add(highlight_command, printf('ctermbg=%d guibg=%s', ctermbg, guibg))
        endif

        if !empty(a:style)
            call add(highlight_command, printf('cterm=%s gui=%s', a:style, a:style))
        endif

        execute join(highlight_command, ' ')
    endfu
