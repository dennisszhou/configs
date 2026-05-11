" Linux kernel coding style (https://www.kernel.org/doc/html/latest/process/coding-style.html).
function! s:StyleKernel() abort
    setlocal cindent
    setlocal cinoptions=:0,l1,t0,(0
    setlocal noexpandtab
    setlocal shiftwidth=8
    setlocal softtabstop=0
    setlocal tabstop=8
    setlocal textwidth=80
    setlocal fo+=ro
    setlocal nojoinspaces
endfunction

" GNU coding style (https://www.gnu.org/prep/standards/html_node/Formatting.html#Formatting).
function! s:StyleGNU() abort
    setlocal cindent
    " From https://gcc.gnu.org/wiki/FormattingCodeForGCC.
    setlocal cinoptions=>4,n-2,{2,^-2,:2,=2,g0,h2,p5,t0,+2,(0,u0,w1,m1
    setlocal noexpandtab
    setlocal shiftwidth=2
    setlocal softtabstop=2
    setlocal tabstop=8
    setlocal textwidth=79
    setlocal fo-=ro
    setlocal joinspaces
endfunction

function! s:PathMatches(paths) abort
    let file_dir = fnamemodify(expand('%:p:h'), ':p')
    for path in a:paths
        let expanded_path = fnamemodify(expand(path), ':p')
        if file_dir ==# expanded_path || stridx(file_dir, expanded_path . '/') == 0
            return 1
        endif
    endfor
    return 0
endfunction

function! s:ApplyWhitelistedStyle() abort
    let linux_match = exists('g:c_linux_style_whitelist')
        \ && s:PathMatches(g:c_linux_style_whitelist)
    let gnu_match = exists('g:c_gnu_style_whitelist')
        \ && s:PathMatches(g:c_gnu_style_whitelist)

    if linux_match && gnu_match
        echoerr 'c.vim: path matches both Linux and GNU style whitelists'
    elseif linux_match
        call s:StyleKernel()
    elseif gnu_match
        call s:StyleGNU()
    endif
endfunction

call s:ApplyWhitelistedStyle()
