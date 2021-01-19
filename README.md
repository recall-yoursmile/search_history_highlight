# Search\_History\_Highlight
***
## Introduction
it is a vim plugin.track string in search and highlight.   
Description:   
  Search and highlight current corsur word of interest in different colors  
  And can switch to search the highlight history.  
  Now support 18 color  
  inspired by highlight and mark plugin  

***
## Update Log
Author: LiCZ recallyoursmile@outlook.com  
Version: 1.0
## Next ToDo
1, add sync function: it used to sync a window highlight to another window.  
2, map vim search /patern to this plugin that you can use vim search as SHHNEW.  
3, map <S-8> to this plugin: SHHNEW.  
4, add user default color support.  
5, other maybe.  

## updated log
Last Modified: 2020-11-11  
      Add support workspace switch function, now only support two workspace. use SHHWorkSpaceSwitch to switch  
Last Modified: 2020-10-25  
      Add SHHSel function, can sel a pattern in history to search.   

***
## Installation
Copy plugin/search_history_highlight.vim to you ~/.vim/plugin  

***

## Usage
### key configure:
*let g:shh_use_default_key_map = 1* in your .vimrc, you will use default key
map, otherwise, no write, you can default by yourself according this default
key map.  
Default key map:  
***
    noremap <F4> :SHHNew<cr>
    vnoremap <F4> :<C-u>SHHVNew<cr>
    inoremap <F4> <C-o>:SHHNew<cr>
    noremap <C-F4> :SHHClearBack<cr>
    noremap <S-F4> :SHHClearAll<cr>
    inoremap <C-F4> <C-o>:SHHClearBack<cr>
    inoremap <S-F4> <C-o>:SHHClearAll<cr>
    noremap <F3> :SHHSwitchB<cr>
    noremap <C-F3> :SHHSwitchN<cr>
    noremap <S-F3> :SHHSel 
    noremap <S-F2> :SHHList<cr>
    noremap <F2> :SHHNext<cr>
    noremap <C-F2> :SHHPrev<cr>
    noremap <C-S-F2> :SHHWorkSpaceSwitch<cr>
***

### Command introduction:
 :SHHNew  
      is to search and highlight the current cusor word, every time have
      different colors

 :SHHVNew
      is to search and highlight the selected character in visual mode

 :SHHClearBack
      is the undo of SHHNew

 :SHHClearAll
      is reset the highlight

 :SHHSwitchN
      is to search the the pattern in the highlight from last to old

 :SHHSwitchB
      is to search the pattern in the highlight from old to last

 :SHHList
      is to list the highlight mark

 :SHHNext
      is to search the next highlight in all highlight

 :SHHPrev
      is to search the prev highlight in the all highlight

 :SHHDebug
   if g:shh\_debug\_en == 1, it will avaliable
   is to echo the internal variable for debug

 :SHH {the pattern}
      is used to highlight and search a pattern if you want
      the {the pattern} is the pattern.
      example
      :SHH my_name  
      is to search and highlight the pattern my_name
  :SHHWorkSpaceSwitch
      to switch workspace. now only support two workspace to switch.


