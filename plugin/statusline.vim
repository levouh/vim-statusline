if exists('g:loaded_statusline')
    finish
endif

let g:loaded_statusline = 1


" Dictionary mapping of all different modes to the text that should be displayed.
let s:sl_current_mode={
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

" Set statusline based on window focus
function! statusline#status()
    " Determine which window is focused
    let l:focused = s:statusline_winid == win_getid(winnr())

    " Setup the statusline formatting
    let statusline=""
    let statusline=focused ? "%#Status1#" : "%#StatusLineNC#"       " First color block, see dim.
    let statusline.="\ %{toupper(s:sl_current_mode[mode()])}\ "     " The current mode.
    let statusline.=focused ? "%#Status2#" : "%#StatusLineNC#"      " Second color block.
    let statusline.="\ %<%F%m%r%h%w\ "                              " File path, modified, readonly, helpfile, preview.
    let statusline.=focused ? "%#Status3#" : "%#StatusLineNC#"      " Third color block.
    let statusline.="\ %Y"                                          " Filetype.
    let statusline.="\ %{''.(&fenc!=''?&fenc:&enc).''}"             " Encoding.
    let statusline.="\ %{&ff}\ "                                    " FileFormat (dos/unix..).
    let statusline.=focused ? "%#Status4#" : "%#StatusLineNC#"      " Second color block.
    let statusline.="%{GitBranchName()}"                            " Git info.
    let statusline.=focused ? "%#Status5#" : "%#StatusNone#"        " No color.
    let statusline.="%="                                            " Right Side.
    let statusline.=focused ? "%#Status4#" : "%#StatusLineNC#"      " Third color block.
    let statusline.="\ col:\ %02v"                                  " Colomn number.
    let statusline.="\ ln:\ %02l/%L\ (%3p%%)\ "                     " Line number / total lines, percentage of document.
    let statusline.=focused ? "%#Status1#" : "%#StatusLineNC#"      " First color block, see dim.
    let statusline.="\ %n\ "                                        " Buffer number.

    return statusline
endfunction

augroup QStatus
    au!

    " Ensure the statusline gets drawn if 'lazyredraw' is enabled.
    au VimEnter * redraw
augroup END
