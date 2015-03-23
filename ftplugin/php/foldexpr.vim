" Vim folding via fold-expr
" Language: PHP
"
" Maintainer: Jake Soward <swekaj@gmail.com>
"
" Options: 
"           b:phpfold_use = 1            - Fold groups of use statements in the global scope.
"           b:phpfold_group_iftry = 0    - Fold if/elseif/else and try/catch/finally
"                                          blocks as a group, rather than each part separate.
"           b:phpfold_group_args = 1     - Group function arguments split across multiple
"                                          lines into their own fold.
"           b:phpfold_group_case = 1     - Fold case and default blocks inside switches.
"           b:phpfold_heredocs = 1       - Fold HEREDOCs and NOWDOCs.
"           b:phpfold_docblocks = 1      - Fold DocBlocks.
"           b:phpfold_doc_with_funcs = 1 - Fold DocBlocks. Overrides b:phpfold_docblocks.
"
" Known Bugs:
"  - In switch statements, the closing } is included in the fold of the last case or 
"    default block.
setlocal foldmethod=expr
setlocal foldexpr=GetPhpFold(v:lnum)

if !exists('b:phpfold_use')
    let b:phpfold_use = 1
endif
if !exists('b:phpfold_group_iftry')
    let b:phpfold_group_iftry = 0
endif
if !exists('b:phpfold_group_args')
    let b:phpfold_group_args = 1
endif
if !exists('b:phpfold_heredocs')
    let b:phpfold_heredocs = 1
endif
if !exists('b:phpfold_docblocks')
    let b:phpfold_docblocks = 1
endif
if !exists('b:phpfold_doc_with_funcs')
    let b:phpfold_doc_with_funcs = 1
endif

" If we want to fold functions with their blocks, we have to fold the blocks.
if b:phpfold_doc_with_funcs
    let b:phpfold_docblocks = 1
endif

" work store
let b:phpfold_closefold = []
let b:phpfold_closefold_after = []
let b:phpfold_last = 0
let b:phpfold_cache = []
let b:phpfold_last = 0
let b:phpfold_debug = 0

function! GetPhpFold(lnum)
    let li = IndentLevel(a:lnum)
    if PhpFoldIncrease(a:lnum)
        return '>' . (l:li+1)
    elseif PhpFoldDecrease(a:lnum, l:li)
        return '<' . (l:li+1)
    else
        return '='
    endif
endfunction

function! PhpFoldIncrease(lnum)
    " Does this line start a fold?

    let line = getline(a:lnum)
    if l:line =~? '\v^\s*(private\s+|public\s+|protected\s+|static\s+)*(class|function)(\s|\()'
      " Start of function or class
      return 1
    elseif b:phpfold_docblocks && l:line =~? '\v^\s*/\*\*' && l:line !~? '\*/'
      " Cause indented multi-line comments (/* */) to be folded.
      return 1
    else
      "anything else
      return 0
    endif
endfunction

function! PhpFoldDecrease(lnum, li)
    " Does this line start a fold?
    let line = getline(a:lnum)

    if l:line =~? '\v\}'
        echom "Line #" . a:lnum . " (indent " . a:li . ") " . line
        " End curly
        " scan back up
        let current = a:lnum - 1
        while l:current > 1
            let li2 = IndentLevel(l:current)
            echom "Scanning up: " . l:current . " has indent " . l:li2 . " cf " . a:li . " #" . a:lnum . " ". getline(l:li2)
            if l:li2 < a:li
                " Oh, there's a line with less indentation. So this one wasn't
                " pertinent.
                return 0
            elseif l:li2 == a:li
                if getline(l:li2) =~? '\v\s*\{'
                    " Ignore this if it starts with {
                else
                  " Ok, this closes a fold if this level of indent opened a fold.
                  return PhpFoldIncrease(l:current)
                endif
            endif
            " go back a bit further.
            let current -= 1
        endwhile
    endif

    " this closing thing is not important.
    return 0
endfunction

function! IndentLevel(lnum)
    return indent(a:lnum) / &shiftwidth
endfunction

function! FindNextDelimiter(lnum, delim, ...)
    let current = a:lnum
    if a:0 > 0
        let limit = current + a:1
    else
        let limit = line('$')
    endif

    while current <= limit
        if getline(current) =~? a:delim
            return current
        endif

        let current += 1
    endwhile

    return -2
endfunction

function! FindPrevDelimiter(lnum, delim, ...)
    let current = a:lnum
    if a:0 > 0
        let limit = current - a:1
    else
        let limit = 1
    endif

    while current >= limit
        if getline(current) =~? a:delim
            return current
        endif

        let current -= 1
    endwhile

    return -2
endfunction

" Looks for a class or function declaration that could have opened the current fold region.
" This is only matters between the declaration and the opening curly, so return error if a curly is found first.
" While this could be done with FindNextDelimiter(), this has a default limit of 10 as there shouldn't ever be more
" than number of implements or arguments
function! FindPrevClassFunc(lnum, ...)
    let current = a:lnum

    " If the limit given is out range, pretend it's 10.
    if a:0 == 0 || a:1 < 1 || a:1 > 10
        let stopLine = current - 10
    else
        let stopLine = current - a:1
    endif

    " If there aren't enough lines above the current line, set the end to the first line
    if stopLine < 1
        let stopLine = 1
    endif

    while current >= stopLine
        if getline(current) =~? '{'
            return -2
        elseif getline(current) =~? '\v(^\s*class|\s*(abstract\s+|public\s+|private\s+|static\s+|private\s+)*function)\s+(\k|\()'
            return current
        endif

        let current -= 1
    endwhile

    return -2
endfunction

function! IsDocBlock(lnum)
    let current = a:lnum
    while current >= 0
        let cline = getline(current)
        if cline =~? '\v^\s*/\*\*'
            return 1
        elseif cline !~? '\v^\s*\*'
            return 0
        endif

        let current -= 1
    endwhile

    return 0
endfunction
