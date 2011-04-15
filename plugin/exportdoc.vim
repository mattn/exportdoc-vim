" File: exportdoc.vim
" Last Change: 15-Apr-2011.
" Version: 0.01
"
" *exportdoc.vim* export inline document from vimscript.
"
"          -------------------------------------------------------
"                ExportDoc: automatic generator for vimscript
"          -------------------------------------------------------
"
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" WebSite: http://mattn.kaoriya.net/
" Repository: http://github.com/mattn/exportdoc-vim
" License: BSD style license
" ===============================================================================
" CONTENTS                                                     *exportdoc-contents*
"    Introduction           |exportdoc-intro|
"    Install                |exportdoc-install|
"    For Writer             |exportdoc-writer|
"    For Reader             |exportdoc-reader|
"
" INTRODUCTION                                                    *exportdoc-intro*
"
"   This help file generating script. To publish several files for vimscript,
"   you need to archive the files as like a vim's runtime directory.
"   But, some user think that vimscript should be portable. The way to
"   install should be "COPY IT TO PLUGIN DIRECTORY".
"   This script is useful for them. If you only type below, then help file
"   will be generated. 
"   However, to work this system, publishing vimscript should in compliance
"   with some rules.
"
" INSTALL                                                       *exportdoc-install*
"
"   Of course! You should only copy exportdoc.vim to your plugin directory.
"
" FOR WRITER                                                     *exportdoc-writer*
"
"   You can write help file in your vimscript.
"   To use this system, you need to add following line into head of your
"    vimscript.
" >
"    " ExportDoc: foobar.txt:2:10:3
" <
"
"   This is mean:
"
"      * output filename is foobar.txt
"      * clip the lines from 2 to 10.
"      * cut the first three characters in comment line. 
"
"   This start line number "2" is second line in head of the comments in your
"   vimscript. If you omit the parameter like below, the whole header comment
"   lines will be document.
" >
"    " ExportDoc: foobar.txt
" <
"  Also you can specify only the first paraemter.
" >
"    " ExportDoc: foobar.txt:2
" <
"
" >
"    " ExportDoc: foobar.txt:2:10
" <
"   If the line become script part(meaning not comment line), this script use
"   the line above for document lines.
"
"   You can specify second parameter as "-2" for end line number. You can see
"   that two lines don't need for document in the below of this file.
"
"   If omit the third parameter, cutting characters become part of the first
"   line of document.
"
" FOR READER                                                     *exportdoc-reader*
"
"   When you get vimscript, you may not have document text file.
"   But the vimscript file may include the document.
"   You can confirm whether the vimscript include it with seeing ExportDoc
"   header. However, perhaps, you won't need to do anything.
"
" ExportDoc: exportdoc.txt:5:-2
" " vim:tw=78:ts=8:ft=help:norl:noet:fen:fdl=0:

function! s:ExportDoc(bang)
  for rtp in split(&rtp, ',')
    let gen = 0
    for s in split(globpath(rtp, "plugin/*.vim"), "\n")
      let d = substitute(s, 'plugin[\\/]\(\w\+\)\.vim$', 'doc/\1.txt', '')
      if filereadable(d) && a:bang != '!'
        continue
      endif
      let h = filter(readfile(s, 0, 200), 'v:val =~ ''^"\s*ExportDoc:''')
      if len(h) == 0
        continue
      endif
      if !isdirectory(rtp . '/doc')
        call mkdir(rtp . '/doc')
      endif
      let t = split(substitute(h[-1], '^"\s*ExportDoc:\s*\(.*\)$', '\1', ''), ':')
      let f = d
      let ll = readfile(s)
      let doc = []
      for l in ll
        if l !~ '^"'
          break
        endif
        call add(doc, l)
      endfor
      if len(t) >= 1
        let f = t[0]
      endif
      if len(t) >= 2
        try
          let doc = doc[str2nr(t[1])-1 :]
        catch /.*/
        endtry
      endif
      if len(t) >= 3
        let e = str2nr(t[2])
        try
          let doc = doc[: e-1]
        catch /.*/
        endtry
      endif
      if len(doc) > 0
        if len(t) >= 4
          let off = str2nr(t[3])
        else
          let off = len(substitute(doc[0], '^\("\s*\).*', '\1', ''))
        endif
        try
          let doc = map(doc, 'v:val[off :]')
          call writefile(doc, d)
          let gen = 1
        catch /.*/
        endtry
      endif
    endfor
    if gen
      exec 'helptags '.escape(rtp, ' \\') . '/doc'
    endif
  endfor
endfunction

call s:ExportDoc(0)
command! -bang -nargs=0 ExportDoc call <sid>ExportDoc('<bang>')


" vim:set et:
