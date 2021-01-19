" File: search_history_highlight.vim
" Author: LiCZ recallyoursmile@outlook.com
" Version: 1.0
" Last Modified: 2020-11-11
"       Add support workspace switch function, now only support two workspace. use SHHWorkSpaceSwitch to switch
" Last Modified: 2020-10-25
"       Add SHHSel function, can sel a pattern in history to search. 
" Description: 
"   Search and highlight current corsur word of interest in different colors
"   And can switch to search the highlight history 
"   inspired by highlight and mark plugin
" Uasge:
"
"  :SHHNew  
"       is to search and highlight the current cusor word, every time have
"       different colors
"
"  :SHHVNew
"       is to search and highlight the selected character in visual mode
"
"  :SHHClearBack
"       is the undo of SHHNew
"
"  :SHHClearAll
"       is reset the highlight
"
"  :SHHSwitchN
"       is to search the the pattern in the highlight from last to old
"
"  :SHHSwitchB
"       is to search the pattern in the highlight from old to last
"
"  :SHHList
"       is to list the highlight mark
"
"  :SHHNext
"       is to search the next highlight in all highlight
"
"  :SHHPrev
"       is to search the prev highlight in the all highlight
"
"  :SHHDebug
"    if g:shh_debug_en == 1, it will avaliable
"    is to echo the internal variable for debug
"
"  :SHH {the pattern}
"       is used to highlight and search a pattern if you want
"       the {the pattern} is the pattern.
"       example
"       :SHH my_name  
"       is to search and highlight the pattern my_name
"   :SHHWorkSpaceSwitch
"       to switch workspace. now only support two workspace to switch.
" configure:
" let g:shh_use_default_key_map = 1 in your .vimrc, you will use default key
" map, otherwise, no write, you can default by yourself according this default
" key map


"avoid loaded again, if has been loaded
if exists("loaded_search_history_highlight") 
   finish
endif

let loaded_search_history_highlight = ""

syntax on


" Define colors for Pattern highlight
exec 'hi SHHColor0   ctermbg = LightGray    ctermfg = White     guibg = #58FAF4 guifg = #000000'
exec 'hi SHHColor1   ctermbg = Magenta      ctermfg = White 	guibg = #ffd1e2 guifg = #000000'
exec 'hi SHHColor2   ctermbg = Green 	    ctermfg = White 	guibg = #d6ffd1 guifg = #000000'
exec 'hi SHHColor3   ctermbg = Yellow 	    ctermfg = White 	guibg = #fff3d1 guifg = #000000'
exec 'hi SHHColor4   ctermbg = DarkCyan 	ctermfg = White 	guibg = #2EFE9A guifg = #000000'
exec 'hi SHHColor5   ctermbg = Cyan 	    ctermfg = White 	guibg = #d1feff guifg = #000000'
exec 'hi SHHColor6   ctermbg = Brown 	    ctermfg = White 	guibg = #F781F3 guifg = #000000'
exec 'hi SHHColor7   ctermbg = LightGreen 	ctermfg = White 	guibg = #FA5858 guifg = #000000'
exec 'hi SHHColor8   ctermbg = Red 	        ctermfg = White 	guibg = #ffff98 guifg = #000000'
exec 'hi SHHColor9   ctermbg = LightBlue    ctermfg = White 	guibg = #FFBF00 guifg = #000000'
exec 'hi SHHColor10  ctermbg = Blue   	    ctermfg = White 	guibg = #e8ffd1 guifg = #000000'
exec 'hi SHHColor11  ctermbg = Gray 	    ctermfg = White 	guibg = #9F81F7 guifg = #000000'
exec 'hi SHHColor12  ctermbg = LightMagenta ctermfg = White 	guibg = #FAAC58 guifg = #424242'
exec 'hi SHHColor13  ctermbg = DarkBlue     ctermfg = White 	guibg = #80FF00 guifg = #424242'
exec 'hi SHHColor14  ctermbg = LightBlue    ctermfg = White 	guibg = #FA58F4 guifg = #424242'
exec 'hi SHHColor15  ctermbg = Blue   	    ctermfg = White 	guibg = #2E64FE guifg = #424242'
exec 'hi SHHColor16  ctermbg = Gray 	    ctermfg = White 	guibg = #c8c8ff guifg = #000000'
exec 'hi SHHColor17  ctermbg = LightMagenta ctermfg = White 	guibg = #ffc8c8 guifg = #000000'

"set max color number in pattern                                                                   
let s:pcolor_max = 18   

"init search history highlight
"All variable here:
" w:shh_search_history_max_num  -- it is max number of search history
" w:shh_search_history          -- it is the array of search history pattern
" w:shh_search_sel_flag         -- it is a sel flag that now select search pattern
" w:shh_color_in_use            -- it is the array that contain the search histoy pattern color num used
" w:shh_color_valid             -- it is the arrary that the color number is valid
" w:shh_now_workspace           -- it is current workspace number
" g:shh_search_history_highlight_max_num

function s:init_shh()
    "search history max_num, max num is 13
    if exists('g:shh_search_history_highlight_max_num')
        if g:shh_search_history_highlight_max_num > s:pcolor_max || g:shh_search_history_highlight_max_num <= 0
            let w:shh_search_history_max_num = s:pcolor_max
        else
            let w:shh_search_history_max_num = g:shh_search_history_highlight_max_num
        endif
    else 
        let w:shh_search_history_max_num = s:pcolor_max
    endif

    "flag of now search history highlight
    if !exists('w:shh_search_sel_flag') | let w:shh_search_sel_flag = 0 | endif
    
    "Search history list
    if !exists('w:shh_search_history') | let w:shh_search_history = [] | endif

    " Color of search history list use
    if !exists('w:shh_color_in_use') | let w:shh_color_in_use = [] | endif

    "List color valid list
    if !exists('w:shh_color_valid') 
        let w:shh_color_valid = [] 
        "init shh_color_valid list
        let i = 0
        while i < w:shh_search_history_max_num
            call add(w:shh_color_valid,0)
            let i = i+1
        endw
    endif
  
    "init for two workspace
    if !exists('w:shh_now_workspace')
        let w:shh_now_workspace = 0
        let w:shh_search_history_0 = []
        let w:shh_search_sel_flag_0 = 0
        let w:shh_color_in_use_0 = []
        let w:shh_color_valid_0 = []

        let w:shh_search_history_1 = []
        let w:shh_search_sel_flag_1 = 0
        let w:shh_color_in_use_1 = []
        let w:shh_color_valid_1 = []
        
        let i=0
        while i < w:shh_search_history_max_num
            call add(w:shh_color_valid_0,0)
            call add(w:shh_color_valid_1,0)
            let i += 1
        endw
    endif
    
    "shh_debug_en
    if !exists('g:shh_debug_en')
        let g:shh_debug_en = 0
    endif

endfunction

"=============================================================================
"Helper Function
"
"Escape Text Function
function! s:shh_EscapeText( text )
	return substitute( escape(a:text, '\' . '^$.*[~'), "\n", '\\n', 'ge' )
endfunction

" get Visual Selection Function
function! s:shh_GetVisualSelection()
	let save_clipboard = &clipboard
	set clipboard= " Avoid clobbering the selection and clipboard registers.
	let save_reg = getreg('"')
	let save_regmode = getregtype('"')
	silent normal! gvy
	let res = getreg('"')
	call setreg('"', save_reg, save_regmode)
	let &clipboard = save_clipboard
	return res
endfunction

"helper function: -1
function! s:shh_minus_one(num,min,max)
    let tmp = a:num - 1
    return (tmp < a:min ? a:max : tmp)
endfunction

"helper function; +1
function! s:shh_add_one(num, min, max)
    let tmp = a:num + 1
    return (tmp > a:max ? a:min : tmp)
endfunction

"get_first from list
function! s:shh_get_first_valid()
    let i=0
    while i < w:shh_search_history_max_num
        if w:shh_color_valid[i] == 0 | return i | endif
        let i= i+1
    endw
    return -1
endfunction

"A function to set highlight
function! s:shh_highlight_set(color_num,pattern)
    let color_match = 'SHHColor' . a:color_num
    let cn = a:color_num + 4
    call matchadd(color_match, a:pattern ,0,cn)
    let w:shh_color_valid[a:color_num] = 1
endfunction

"A function of clear high light
function! s:shh_highlight_clr(color_num)
    if w:shh_color_valid[a:color_num] == 1
        let w:shh_color_valid[a:color_num] = 0
        let cn = a:color_num + 4
        call matchdelete(cn)
    endif
endfunction

"Look for highlighted, if highlighted, return position, else return -1
function! s:shh_look_have(pattern)
   let i=0
   while i < len(w:shh_search_history)
        if a:pattern ==# w:shh_search_history[i] | return i | endif
        let i += 1
   endw
   return -1
endfunction

"Add a new mark of a pattern
function! s:shh_mark_new(pattern)
    let len_pattern = len(w:shh_search_history) 
    " if full, delete oldest mark
    if len_pattern == w:shh_search_history_max_num 
        call <SID>shh_mark_del(len_pattern-1)
    endif
    let tmp_color = <SID>shh_get_first_valid() 
    call <SID>shh_highlight_set(tmp_color, a:pattern)
    call insert(w:shh_search_history, @/, 0)
    call insert(w:shh_color_in_use, tmp_color, 0)
    let w:shh_search_sel_flag = 0
endfunction

"Del a mark for a del_point
function! s:shh_mark_del(del_point)
    let tmp_color = w:shh_color_in_use[a:del_point]
    call remove(w:shh_search_history, a:del_point)
    call remove(w:shh_color_in_use, a:del_point)
    cal <SID>shh_highlight_clr(tmp_color)
endfunction


"=============================================================================
"Command Event Function
"
"Add a new mark of a pattern
"pattern: the pattern you want to highlight
"mode: 
"   1, cwoed: highlight current cursor word
"   2, vword: highlight selectionm word in vs mode
"   3, else: command mode, you can input any
function! s:shh_highlight_new(pattern,mode)
    if a:pattern != ''
        if a:mode == 'cword'
            let tmp_p = <SID>shh_EscapeText(a:pattern)
            let @/ = '\<' . tmp_p . '\>'
            if tmp_p =~# '^\k\+$'
                let tmp_p = '\<' . (&ignorecase ? '\c' : '\C') . tmp_p .'\>'
            endif
            " echohl None |echo "Now Search: " | exe "echohl Search" | echon @/ | echohl None
        elseif a:mode == 'vword'
            let tmp_p = <SID>shh_GetVisualSelection()
            let tmp_p = <SID>shh_EscapeText(tmp_p)
            if tmp_p =~# '^\k\+$'
                let tmp_p =  (&ignorecase ? '\c' : '\C') . tmp_p
            endif
            let @/ = tmp_p
        else
            let tmp_p = (&ignorecase ? '\c' : '\C') . a:pattern
            let @/ = tmp_p
            " echohl None |echo "Now Search: " | exe "echohl Search" | echon @/ | echohl None
        endif
        
        echohl None |echo "Now Search: " | exe "echohl Search" | echon @/ | echohl None
        let tmp_pos = <SID>shh_look_have(@/)
        if tmp_pos == -1 | call <SID>shh_mark_new(tmp_p) | else | let w:shh_search_sel_flag = tmp_pos | endif
    endif
endfunction

"Switch the search select from history
" mode==1: search back
" mode==0: search ahead
function! s:shh_search_switch(mode)
    if len(w:shh_search_history) > 0
        if a:mode == 1
            let w:shh_search_sel_flag = <SID>shh_add_one(w:shh_search_sel_flag,0,len(w:shh_search_history)-1)
        else
            let w:shh_search_sel_flag = <SID>shh_minus_one(w:shh_search_sel_flag,0,len(w:shh_search_history)-1)
        endif
        let @/ = w:shh_search_history[w:shh_search_sel_flag]
        echohl None |echo "Now Search: " | exe "echohl Search" | echon @/ | echohl None
    else
        echohl None | exe "echohl ErrorMsg" | echo "No Highlight" | echohl None        
    endif
endfunction

"clear highlight
function! s:shh_highlight_clear(mode)
    if len(w:shh_search_history) > 0
        if a:mode == 'all'
            while len(w:shh_search_history) > 0
                call <SID>shh_mark_del(0)
            endw
            echohl None | exe "echohl Todo" | echon "Clear All Highlight" | echohl None
        else
            call <SID>shh_mark_del(w:shh_search_sel_flag)
            if len(w:shh_search_history) == 0 
                let w:shh_search_sel_flag = 0
            elseif w:shh_search_sel_flag == 0
                let w:shh_search_sel_flag = 0
                let @/ = w:shh_search_history[w:shh_search_sel_flag]
            else
                let w:shh_search_sel_flag = w:shh_search_sel_flag - 1
                let @/ = w:shh_search_history[w:shh_search_sel_flag]
            endif
            echohl None |echo "Now Search: " | exe "echohl Search" | echon @/ | echohl None
        endif
    endif
endfunction

"Switch another workspace function
function! s:shh_switch_workspace()
    "clear mark for now workspace
    let i = 0
    while i<len(w:shh_search_history)
        if w:shh_color_valid[w:shh_color_in_use[i]]==1
            let cn = w:shh_color_in_use[i] + 4
            call matchdelete(cn)
        endif
        let i +=1
    endw

    "save now state variable 
    if w:shh_now_workspace == 0
        let w:shh_search_history_0 = copy(w:shh_search_history)
        let w:shh_search_sel_flag_0 = w:shh_search_sel_flag
        let w:shh_color_in_use_0 = copy(w:shh_color_in_use)
        let w:shh_color_valid_0 = copy(w:shh_color_valid)
    else
        let w:shh_search_history_1 = copy(w:shh_search_history)
        let w:shh_search_sel_flag_1 = w:shh_search_sel_flag
        let w:shh_color_in_use_1 = copy(w:shh_color_in_use)
        let w:shh_color_valid_1 = copy(w:shh_color_valid)
    endif

    "switch workspace
    if w:shh_now_workspace == 0
        let w:shh_now_workspace = 1
        let w:shh_search_history = copy(w:shh_search_history_1)
        let w:shh_search_sel_flag = w:shh_search_sel_flag_1
        let w:shh_color_in_use = copy(w:shh_color_in_use_1)
        let w:shh_color_valid = copy(w:shh_color_valid_1)
    else
        let w:shh_now_workspace = 0
        let w:shh_search_history = copy(w:shh_search_history_0)
        let w:shh_search_sel_flag = w:shh_search_sel_flag_0
        let w:shh_color_in_use = copy(w:shh_color_in_use_0)
        let w:shh_color_valid = copy(w:shh_color_valid_0)
    endif

    "re-mark 
    let i = 0
    while i<len(w:shh_search_history)
        if w:shh_color_valid[w:shh_color_in_use[i]]==1
            let color_match = 'SHHColor' . w:shh_color_in_use[i]
            let cn = w:shh_color_in_use[i] + 4
            call matchadd(color_match, w:shh_search_history[i], 0, cn)
        endif
        let i +=1
    endw
    
    echohl None | exe "echohl Todo" | echon "WorkSpace is " . w:shh_now_workspace | echohl None
endfunction

"To search next highlight in the all highlight
function! s:shh_next_highlight(cnt)
    if len(w:shh_search_history) > 0
        let cnt = a:cnt
        let wrap = 0
        while cnt > 0
            let nxt = line("$")+1
            for hlmtch in getmatches()
                let flag = wrap==0 ? 'nW' : 'nw'
                let hlmtchnxt = search(hlmtch["pattern"],flag)
                if 0 < hlmtchnxt && hlmtchnxt < nxt
                    let nxt = hlmtchnxt 
                    let pat = hlmtch["pattern"]
                endif
            endfor
            if nxt <= line("$")
                let flag = wrap==0 ? 'W' : 'w'
                call search(pat,flag)
                echohl None |echo "Now Search: " | exe "echohl Search" | echon pat | echohl None
                let wrap = 0
                let cnt -=1
            else
                if wrap == 1
                    echo "no succeeding Highlight patterns!"
                    break
                endif
                let wrap = 1 
            endif
        endwhile
    else
        echohl None | exe "echohl ErrorMsg" | echo "No Highlight" | echohl None
    endif
endfunction

"To search prev highlight in the all highlight
function! s:shh_prev_highlight(cnt)
    if len(w:shh_search_history) > 0
        let cnt = a:cnt
        let wrap = 0
        while cnt > 0
            let prv = 0
            for hlmtch in getmatches()
                let flag = wrap==0 ? 'nbW' : 'nbw'
                let hlmtchprv = search(hlmtch["pattern"],flag)
                if hlmtchprv > prv
                    let prv = hlmtchprv
                    let pat = hlmtch["pattern"]
                endif
            endfor
            if prv >= 1
                let flag = wrap==0 ? 'bW' : 'bw'
                call search(pat,flag)
                echohl None |echo "Now Search: " | exe "echohl Search" | echon pat | echohl None
                let wrap = 0 
                let cnt -= 1
            else
                if wrap == 1
                    echo "no succeeding Highlight patterns!"
                    break
                endif
                let wrap = 1
            endif
        endwhile
    else
        echohl None | exe "echohl ErrorMsg" | echo "No Highlight" | echohl None
    endif
endfunction

"To List have word in highlight
function! s:shh_list_highlight()
    if len(w:shh_search_history) > 0
        echohl None | exe 'echohl VimAutoEvent' | echo "  Group   InSearch\t  Pattern" | echohl None
        let num = 0
        let i = 0
        while  i < len(w:shh_search_history)
            let ccol = w:shh_color_in_use[i] + 4
            echohl None | exe 'echohl SHHColor'.ccol | echo "   " . i . "\t" | echohl None
            echon "  "
            if @/ == w:shh_search_history[i]
                echohl None | exe 'echohl Search' | echon "  *  " | echohl None
            else
                echon "     "
            endif
            echon "\t  " . w:shh_search_history[i]
            let i += 1
        endw
    else
        echohl None | exe "echohl ErrorMsg" | echo "No Highlight" | echohl None
        " call inputsave() | call input("Please sel: ") | call inputrestore()
    endif
endfunction

function! s:shh_select_a_mark(point)
    if a:point =~ '\d\+'
        if len(w:shh_search_history) > a:point
            let w:shh_search_sel_flag = a:point
            let @/ = w:shh_search_history[a:point]
            echohl None |echo "Now Search: " | exe "echohl Search" | echon @/ | echohl None
        else
            echohl None | exe "echohl ErrorMsg" | echo "Out Of Range" | echohl None
        endif
    else
        echohl None | exe "echohl ErrorMsg" | echo "Not a Valid Input" | echohl None
    endif
endfunction


"For debug
function! s:shh_debug()
    echomsg 'max history and highlight num: ' . w:shh_search_history_max_num
    echo w:shh_color_valid
    echo w:shh_color_in_use
    echo w:shh_search_history
endfunction

function! s:shh_test_input()
    let tmp = input("Please input: ")
    " exec 'normal! '
    if tmp =~ '\d\+'
        echo tmp
    else
        echo "   NO---"
    endif
endfunction


"=============================================================================
"init
call s:init_shh()
            
"Auto Group
augroup InitSHH
    autocmd!
    autocmd BufWinEnter,WinEnter,TabEnter * call <SID>init_shh()
augroup END

"=============================================================================
"command set
command! -bar SHHNew :call <SID>shh_highlight_new(expand("<cword>"), "cword")
command! SHHVNew :call <SID>shh_highlight_new("no","vword")
command! -nargs=*  SHH :call <SID>shh_highlight_new(<q-args>,"else")
command! -bar SHHClearBack :call <SID>shh_highlight_clear('new')
command! -bar SHHClearAll :call <SID>shh_highlight_clear('all')
command! -bar SHHSwitchN :call <SID>shh_search_switch(0)
command! -bar SHHSwitchB :call <SID>shh_search_switch(1)
command! -count=1 SHHNext :call <SID>shh_next_highlight(<count>)
command! -count=1 SHHPrev :call <SID>shh_prev_highlight(<count>)
command! SHHList :call <SID>shh_list_highlight()
command! -nargs=1 SHHSel :call <SID>shh_select_a_mark(<f-args>)
command! SHHWorkSpaceSwitch : call <SID>shh_switch_workspace()
"debug mode enable
if g:shh_debug_en == 1
    command! SHHDebug :call <SID>shh_debug()
endif

command! SHHINPUT :call <SID>shh_test_input()
"=============================================================================
"configure default map write:
"   let g:shh_use_default_key_map = 1 
"in your .vimrc, otherwise, nothing needed.
if exists('g:shh_use_default_key_map') && g:shh_use_default_key_map == 1
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
endif
