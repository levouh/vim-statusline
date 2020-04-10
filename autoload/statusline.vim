" --- Globals {{{

    let s:palette = {}
    let s:palette.blackest = [232, '#080808']
    let s:palette.black = [234, '#1c1c1c']
    let s:palette.gray01 = [235, '#262626']
    let s:palette.gray02 = [238, '#444444']
    let s:palette.gray03 = [239, '#4e4e4e']
    let s:palette.gray04 = [240, '#585858']
    let s:palette.gray05 = [242, '#666666']
    let s:palette.gray06 = [243, '#767676']
    let s:palette.gray07 = [244, '#808080']
    let s:palette.gray08 = [245, '#8a8a8a']
    let s:palette.gray09 = [246, '#949494']
    let s:palette.gray10 = [247, '#9e9e9e']
    let s:palette.gray11 = [248, '#a8a8a8']
    let s:palette.gray12 = [249, '#b2b2b2']
    let s:palette.gray13 = [250, '#bcbcbc']
    let s:palette.gray14 = [251, '#c6c6c6']
    let s:palette.gray15 = [254, '#e4e4e4']
    let s:palette.white = [255, '#eeeeee']

    let s:palette.comments = copy(s:palette.gray03)

    let s:palette.purple = [62, '#5f5fd7']
    let s:palette.brown = [94, '#875f00']
    let s:palette.blue = [24, '#005f87']
    let s:palette.lightblue = [31, '#00afff']
    let s:palette.green = [29, '#00875f']
    let s:palette.red = [88, '#870000']
    let s:palette.magenta = [89, '#87005f']

" }}}

" --- Public Functions {{{

    function! statusline#set_hi()
        " Used for statusline colors based on focused window
        call s:hi('Status1', s:palette.gray01, s:palette.gray15, 'bold')
        call s:hi('Status2', s:palette.gray01, s:palette.gray11, 'bold')
        call s:hi('Status3', s:palette.gray01, s:palette.gray09, 'bold')
        call s:hi('Status4', s:palette.gray01, s:palette.gray07, 'bold')
        call s:hi('Status5', s:palette.gray01, s:palette.gray01, 'bold')
        call s:hi('StatusInsert', s:palette.gray08, s:palette.gray01, 'bold')
        call s:hi('StatusNone', s:palette.gray08, s:palette.gray01, 'bold')
    endfunction

    function! statusline#tab() abort
        let l:tabstr = ''

        for i in range(tabpagenr('$'))
            let l:tabidx = i + 1

            " Select the highlighting
            if l:tabidx == tabpagenr()
                let l:tabstr .= '%#TabLineSel#'
            else
                let l:tabstr .= '%#TabLine#'
            endif

            " Set the tab page number (for mouse clicks)
            let l:tabstr .= '%' . l:tabidx . 'T'

            " Label should be tab working directory
            let l:tabstr .= ' %{getcwd(0, ' . l:tabidx . ')} '
        endfor

        " After the last tab fill with TabLineFill and reset tab page nr
        let l:tabstr .= '%#TabLineFill#%T'

        return l:tabstr
    endfunction

    " Set statusline based on window focus
    function! statusline#status() abort
        if !exists('g:_statusline_mode')
            call s:setup_mode_dict()
        endif

        " Determine which window is focused
        let l:focused = g:statusline_winid == win_getid(winnr())

        if mode() == 'i'
            let l:first_block = 'StatusInsert'
        else
            let l:first_block = 'Status1'
        endif

        " Setup the statusline formatting
        let l:statusline=""
        let l:statusline=focused ? "%#" . l:first_block . "#" : "%#StatusNone#"    " First color block
        let l:statusline.="\ %{toupper(g:_statusline_mode[mode()])}\ "             " The current mode
        let l:statusline.=focused ? "%#Status2#" : "%#StatusNone#"                 " Second color block
        let l:statusline.="\ %<%F%m%r%h%w\ "                                       " File path, modified, readonly, helpfile, preview
        let l:statusline.=focused ? "%#Status3#" : "%#StatusNone#"                 " Third color block
        let l:statusline.="\ %Y"                                                   " Filetype
        let l:statusline.="\ %{''.(&fenc!=''?&fenc:&enc).''}"                      " Encoding
        let l:statusline.="\ %{&ff}\ "                                             " FileFormat (dos/unix..)
        let l:statusline.=focused ? "%#Status4#" : "%#StatusNone#"                 " Second color block
        let l:statusline.="%{statusline#git_branch_name()}"                        " Git info
        let l:statusline.=focused ? "%#Status5#" : "%#StatusNone#"                 " No color
        let l:statusline.="%="                                                     " Right Side
        let l:statusline.=focused ? "%#Status4#" : "%#StatusNone#"                 " Third color block
        let l:statusline.="\ col:\ %02v"                                           " Colomn number
        let l:statusline.="\ ln:\ %02l/%L\ (%3p%%)\ "                              " Line number / total lines, percentage of document
        let l:statusline.=focused ? "%#Status1#" : "%#StatusNone#"                 " First color block, see dim
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

    function! s:hi(group, fg_color, bg_color, style)
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
    endfunction
