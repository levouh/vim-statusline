## vim-statusline

_A simple statusline._

### Support

_Vim_: 8.2.227  
_OS_: Linux

### Installation

```
Plug 'levouh/vim-statusline'
```

### Setup

Simply tell Vim what function you want to call to set your statusline:

```
set statusline=%!statusline#status()
```

### Recommended Settings

Use mode information in the statusline, rather than have Vim display it:

```
set noshowmode
```

Show the statusline even when not split:

```
set laststatus=2
```

### Configuration

No configuration is supported at the moment, but might be added in the future to set colors, etc. Right now the colors for the statusline are based off of those defined by the terminal emulator being used.

### Mentions

Git branch parsing information is taken from [vim-gitbranch](https://github.com/itchyny/vim-gitbranch).
