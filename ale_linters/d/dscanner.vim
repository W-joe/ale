" Author: wjoe
" Description: "dscanner for D files"

function! ale_linters#d#dscanner#GetExecutable(buffer) abort
    return 'dscanner'
endfunction

function! ale_linters#d#dscanner#DScannerCommand(buffer, dub_output, meta) abort
    let l:command = ale_linters#d#dscanner#GetExecutable(a:buffer)
    return l:command . ' --styleCheck'
endfunction

function! ale_linters#d#dscanner#RunCommand(buffer) abort
    let l:command = ale_linters#d#dscanner#GetExecutable(a:buffer)

    return ale#command#Run(a:buffer, l:command, function('ale_linters#d#dscanner#DScannerCommand'))
endfunction

function! ale_linters#d#dscanner#Handle(buffer, lines) abort
    " Matches patterns lines like the following:
    " /tmp/source.d(48:9)[warn]: Local imports should specify the symbols ...
    let l:pattern = '^[^(]\+((\d\+):(\d\+))\[([^:])\+: (.*)'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1],
        \   'col': l:match[2],
        \   'type': l:match[3] is# 'warn]' ? 'w' : 'e',
        \   'text': l:match[4],
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('d', {
\   'name': 'dscanner',
\   'executable': function('ale_linters#d#dscanner#GetExecutable'),
\   'command': function('ale_linters#d#dscanner#RunCommand'),
\   'callback': 'ale_linters#d#dscanner#Handle',
\   'output_stream': 'stdout',
\})
