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

function! GetPhpFold(lnum)
    let line = getline(a:lnum)
    if line == 1
      let b:phpfold_closefold = []
      let b:phpfold_closefold_after = []
      let b:phpfold_last = 0
    endif

    " Empty lines get the same fold level as the line before them.
    " e.g. blank lines between class methods continue the class-level fold.
    if line =~? '\v^\s*$'
        return b:phpfold_last
    endif
    let l:il = IndentLevel(a:lnum)

    echom 'line ' . a:lnum . ' Indent:' . l:il . ' closes:' . join(b:phpfold_closefold, ',') . ' closes_a:' . join(b:phpfold_closefold_after, ',') . ' string: ' . line
    " If this line is at a level of indentation we should look out for, close
    " the fold.
    if len(b:phpfold_closefold)>0
      " We are looking out for things to close

      if (a:lnum > b:phpfold_closefold_after[-1]) && (b:phpfold_closefold[-1] == l:il)
        echom 'line ' . a:lnum . ' ENDS: ' . line
        let b:phpfold_closefold=b:phpfold_closefold[0:-2]
        let b:phpfold_closefold_after=b:phpfold_closefold_after[0:-2]
        let l:thisfold = '<' .b:phpfold_last
        if b:phpfold_last == 0
          echom 'hmmm. already at 0 but closing a fold?!'
        else
          let b:phpfold_last -= 1
        endif
        return l:thisfold
      endif
    endif

    " @todo: support folding docblock as part of the code.

    " Does this line start a fold?
    if line =~? '\v^\s*(private\s+|public\s+|protected\s+|static\s+)*(class|function)(\s|\()'
      echom 'line ' . a:lnum . ' STARTS: ' . line
      " Store the current indent as an important one to look out for
      let b:phpfold_closefold=add(b:phpfold_closefold, l:il)
      " But we must only look out for it after the opening curly
      let nextCurly = FindNextDelimiter(a:lnum, '{')
      let b:phpfold_closefold_after=add(b:phpfold_closefold_after, nextCurly)
      let b:phpfold_last += 1
      return '>' . b:phpfold_last
    elseif b:phpfold_docblocks && line =~? '\v^\s*/\*\*' && line !~? '\*/'
      " Cause indented multi-line comments (/* */) to be folded.
      echom 'line ' . a:lnum . ' STARTS: ' . line
      " Store the current indent as an important one to look out for
      let b:phpfold_closefold=add(b:phpfold_closefold, l:il)
      " But we must only look out for it at the line with the closing */
      let endComment = FindNextDelimiter(a:lnum, '*/') - 1
      let b:phpfold_closefold_after=add(b:phpfold_closefold_after, endComment)
      let b:phpfold_last += 1
      return '>' . b:phpfold_last
    endif

    return b:phpfold_last
    " -------------------------------------------------------------

    if b:phpfold_docblocks
        " Cause indented multi-line comments (/* */) to be folded.
        if line =~? '\v^\s*/\*\*' && line !~? '\*/'
            return '>'.(IndentLevel(a:lnum)+1)
        elseif line =~? '\v^\s*\*/@!' && IsDocBlock(a:lnum-1)
            return IndentLevel(a:lnum)+1
        elseif line =~? '\v^\s*\*/'
            if b:phpfold_doc_with_funcs && getline(a:lnum+1) =~?  '\v\s*(abstract\s+|public\s+|private\s+|static\s+|private\s+)*function\s+(\k|\()'
                return IndentLevel(a:lnum)+1
            else
                return '<' . (IndentLevel(a:lnum)+1)
            endif
        endif
    endif

    if b:phpfold_use
        " Fold blocks of 'use' statements that have no indentation.
        " i.e. namespace imports
        if line =~? '\v^use\s+' && getline(a:lnum+1) =~? '\v^(use\s+)@!'
            " Stop the fold at the last use statement.
            return '<1'
        elseif line =~? '\v^use\s+'
            return '1'
        endif
    endif

    " handle class methods and independent functions
    if line =~? '\v\s*(abstract\s+|public\s+|private\s+|static\s+|private\s+)*function\s+(\k|\()' && line !~? ';$'
        if b:phpfold_doc_with_funcs
            return IndentLevel(a:lnum)+1
        else
            return '>'.(IndentLevel(a:lnum)+1)
        endif
    endif

    if line =~? '\vfunction\s+(\k|\().*;$'
        return '<'.(IndentLevel(a:lnum)+1)
    endif

    if line =~? '\v^\s*class\s+\k'
        " The code inside the class or function determines the fold level, 
        " and it starts after the curly.  However, the curly may not always 
        " be right after the class or function declaration, so search for it.
        let nextCurly = FindNextDelimiter(a:lnum, '{')
        return '>' . IndentLevel(nextnonblank(nextCurly + 1))
    elseif line =~? '{' && line !~? '\v^\s*\*'
        " The fold level of the curly is determined by the next non-blank line
        return IndentLevel(a:lnum) + 1
    elseif line =~? '\v^\s*\*@!\}(\s*(else|catch|finally))@!'
        " The fold level the closing curly closes is determined by the previous non-blank line
        " But only if not followed by an else, catch, or finally
        return '<' . (IndentLevel(a:lnum)+1)
    endif

    if !b:phpfold_group_iftry
        " If the next line is followed by an opening else, catch, or finally statement, then this 
        " line closes the current fold so that the else/catch/finally can open a new one.
        if getline(a:lnum+1) =~? '\v}\s*(else|catch|finally)'
            return '<' . IndentLevel(a:lnum)
        endif
    endif

    if b:phpfold_group_args
        " Increase the foldlevel by 1 for function and closure arguments and use vars that are on
        " multiple lines.
        let prevClassFunc = FindPrevClassFunc(a:lnum)
        if prevClassFunc > 0 && getline(a:lnum-1) =~? '\v\([^\)]*$'
            return 'a1'
        elseif prevClassFunc > 0 && getline(a:lnum+1) =~? '\v^\s*[^\(]*\)'
            return 's1'
        elseif prevClassFunc > 0
            return '='
        endif
    endif

    " If the line has an open ( ) or [ ] pair, it probably starts a fold
    if line =~? '\v(\(|\[)[^\)\]]*$' 
        if b:phpfold_group_iftry && line =~? '\v}\s*(elseif|catch)'
            " But don't start a fold if we're grouping if/elseif/else and try/catch
            return IndentLevel(a:lnum)+1
        else
            return 'a1'
        endif
    elseif line =~? '\v^\s*([\(\[].*)@!(\)|\])'
        return 's1'
    endif

    " Fold switch case and default blocks together
    if line =~? '\v^\s*default:'
        return '>' . (IndentLevel(a:lnum)+1)
    elseif line =~? '\v^\s*case\s*.*:'
        if  getline(a:lnum-1) !~? '\v^\s*case\s*.*:' 
            return '>' .(IndentLevel(a:lnum)+1)
        else
            return IndentLevel(a:lnum)+1
        endif
    endif

    if b:phpfold_heredocs
        " Fold the here and now docs
        if line =~? "<<<[a-zA-Z_][a-zA-Z0-9_]*$"
            return '>'.(IndentLevel(a:lnum)+1)
        elseif line =~? "<<<'[a-zA-Z_][a-zA-Z0-9_]*'$"
            return '>'.(IndentLevel(a:lnum)+1)
        elseif line =~? "^[a-zA-Z_][a-zA-Z0-9_]*;$"
            " heredocs and now docs end the same way, so we have to check for both starts and see which 
            " appeared latest in the file.  We then assume that one opened the fold.
            let heredoc = FindPrevDelimiter(a:lnum-1, '<<<'.strpart(line, 0, strlen(line)-1))
            let nowdoc = FindPrevDelimiter(a:lnum-1, "<<<'".strpart(line, 0, strlen(line)-1)."'")
            let startLine = -1
            if heredoc > nowdoc
                let startLine = heredoc
            elseif nowdoc > heredoc
                let startLine = nowdoc
            endif
            if startLine >= 0
                return '<'.(IndentLevel(startLine)+1)
            endif
        endif
    endif

    if getline(a:lnum+1) =~? '\v^\s*}' && (IndentLevel(a:lnum)-IndentLevel(a:lnum+1)) > 1
       return '<' . IndentLevel(a:lnum)
   endif

    return '='
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
