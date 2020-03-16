" Linux kernel coding style (https://www.kernel.org/doc/html/latest/process/coding-style.html).
function! StyleLinux()
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
function! StyleGNU()
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

function! s:GuessStyle()
    let comment = 0
    for line in getline(1, 1000)
        if !len(line)
            continue
        endif
        if line =~# '^\s*/\*'
            let comment = 1
        endif
        if comment
            if line =~# '\*/'
                let comment = 0
            endif
            continue
        endif
        if line =~# '^    {'
            call StyleGNU()
            return
        endif
    endfor
    call StyleLinux()
endfunction

silent call s:GuessStyle()
