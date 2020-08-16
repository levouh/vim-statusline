" Palette {{{1

    let s:palette = {}

    let s:palette.black        = [235, '#1C1C1C']
    let s:palette.none         = ['NONE', 'NONE']

    let s:palette.color00      = [235, '#555555']
    let s:palette.color01      = [235, '#696969']
    let s:palette.color02      = [238, '#7E7E7E']
    let s:palette.color03      = [239, '#949494']
    let s:palette.color04      = [240, '#AAAAAA']
    let s:palette.color05      = [242, '#C1C1C1']
    let s:palette.color06      = [243, '#D8D8D8']
    let s:palette.color07      = [244, '#F0F0F0']

fu! statusline#set_hi() " {{{1
    " Used for statusline colors based on focused window
    "
    " Different blocks within the statusline itself
    call s:hi('Status1', s:palette.black, s:palette.color07, 'bold')
    call s:hi('Status2', s:palette.black, s:palette.color05, 'bold')
    call s:hi('Status3', s:palette.black, s:palette.color03, 'bold')
    call s:hi('Status4', s:palette.black, s:palette.color01, 'bold')

    " Highlight text in a different color
    call s:hi('StatusText', s:palette.color05, s:palette.color01, 'bold')

    " The block separator between blocks on different sides
    call s:hi('StatusSep', s:palette.black, s:palette.black, 'bold')

    " The default to use for all statusline parts when not focused
    call s:hi('StatusNone', s:palette.color02, s:palette.black, 'bold')
endfu

fu! statusline#status() abort " {{{1
    " Set statusline based on window focus
    if !exists('g:_statusline_mode')
        call s:setup_mode_dict()
    endif

    " Determine which window is focused
    let focused = g:statusline_winid == win_getid(winnr())

    if focused
        return s:focused_statusline()
    else
        return s:unfocused_statusline()
    endif
endfu

fu! statusline#git_detect(path) abort " {{{1
    " Detect if a directory is part of a git directory
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

fu! statusline#git_branch_name() abort " {{{1
    " Get the name of the current git branch if it exists
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

fu! statusline#filepath() abort " {{{1
    let filepath = ""
    let bufpath = expand("%:f")

    if empty(bufpath)
        let bufpath = '[No Name]'
    endif

    if &buftype != "terminal"
        let filepath .= fnamemodify(bufpath, ':.')
        let filepath .= &modified ? '*' : ''
        let filepath .= &ro ? ' RO ' : ' '
    else
        let filepath .= bufpath
        let filepath .= ' '
    endif

    return filepath
endfu

fu! s:setup_mode_dict() " {{{1
    " Dictionary mapping of all different modes to the text that should be displayed
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

fu! s:git_branch_dir(path) abort " {{{1
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

fu! s:hi(group, fg_color, bg_color, style) " {{{1
    " Function called to setup a particular highlight group
    let highlight_command = ['hi!', a:group]
    "                                 │
    "                                 └ the name of the group

    if !empty(a:fg_color)
        let [ctermfg, guifg] = a:fg_color
        let cterm_format = type(ctermfg) is# v:t_string ? '%s' : '%d'
        let printf_str = 'ctermfg=' .. cterm_format .. ' guifg=%s'

        call add(highlight_command, printf(printf_str, ctermfg, guifg))
    endif

    if !empty(a:bg_color)
        let [ctermbg, guibg] = a:bg_color
        let cterm_format = type(ctermbg) is# v:t_string ? '%s' : '%d'
        let printf_str = 'ctermbg=' .. cterm_format .. ' guibg=%s'

        call add(highlight_command, printf(printf_str, ctermbg, guibg))
    endif

    let style = empty(a:style) ? 'NONE' : a:style

    call add(highlight_command, printf('cterm=%s gui=%s', style, style))

    exe join(highlight_command, ' ')
endfu

fu! s:focused_statusline() " {{{1
    " Setup the statusline formatting for any unfocused window
    let statusline=""

    let statusline="%#Status1#"                                        " First color block
    let statusline.="\ %{toupper(g:_statusline_mode[mode()])}\ "       " The current mode
    let statusline.="%#Status2#"                                       " Second color block
    let statusline.="\ %<%{statusline#filepath()}"                     " File path, modified, readonly
    let statusline.="%#Status3#"                                       " Third color block
    let statusline.="%(\ %Y%)"                                         " Filetype
    let statusline.="\ %{'' .. (&fenc != '' ? &fenc : &enc) .. ''}"    " Encoding
    let statusline.="\ %{&ff}\ "                                       " File format (DOS/UNIX)
    let statusline.="%#Status4#"                                       " Fourth color block
    let statusline.="%<%{statusline#git_branch_name()}"                " Git info
    let statusline.="%#StatusSep#"                                     " No color
    let statusline.="%="                                               " Right Side
    let statusline.="%#StatusText#"                                    " Text for line/column section
    let statusline.="\ col:"                                           " Colomn text
    let statusline.="%#Status4#"                                       " Third color block
    let statusline.="\ %02v"                                           " Column number
    let statusline.="%#StatusText#"                                    " Text for line/column section
    let statusline.="\ ln:"                                            " Line text
    let statusline.="%#Status4#"                                       " Third color block
    let statusline.="\ %02l/%L\ (%3p%%)\ "                             " Line number / total lines, percentage of document
    let statusline.="%#Status1#"                                       " Fifth color block, see dim
    let statusline.="\ %n\ "                                           " Buffer number

    return statusline
endfu

fu! s:unfocused_statusline() " {{{1
    " Setup the statusline formatting for any unfocused window
    let statusline=""

    let statusline="%#StatusNone#"                                     " Highlight for all unfocused blocks
    let statusline.="\ %<%{statusline#filepath()}"                     " File path, modified, readonly
    let statusline.="%(\ %Y%)"                                         " Filetype
    let statusline.="\ %{'' .. (&fenc != '' ? &fenc : &enc) .. ''}"    " Encoding
    let statusline.="\ %{&ff}\ "                                       " File format (DOS/UNIX)
    let statusline.="%<%{statusline#git_branch_name()}"                " Git info
    let statusline.="%="                                               " Right Side
    let statusline.="\ col:\ %02v"                                     " Colomn number
    let statusline.="\ ln:\ %02l/%L\ (%3p%%)\ "                        " Line number / total lines, percentage of document
    let statusline.="\ %n\ "                                           " Buffer number

    return statusline
endfu
