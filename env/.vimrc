" set nocp " :-)
" turn these ON:
" set digraph ek hidden ruler sc vb wmnu
" turn these OFF:
"  set noeb noet nosol
" non-toggles:
"  set bs=2 fo=cqrt ls=2 shm=at tw=160 ww=<,>,h,l
"  set comments=b:#,:%,fb:-,n:>,n:)
"  set list listchars=tab:»·,trail:·
"  set viminfo=%,'50,\"100,:100,n~/.viminfo
" settings which are the default
" (at least with "nocompatible" anyway):
" set smd sw=8 ts=8
" mappings:
"  map K     <NUL>
"  map <C-Z> :shell
"  map ,F :view    $VIMRUNTIME/filetype.vim
"  map ,SO :source $VIMRUNTIME/syntax/
"  map ,V  :view   $VIMRUNTIME/syntax/
" autocommands:
"  au FileType mail set tw=70
" some colors:  "white on black"
"  hi normal   ctermfg=black  ctermbg=white guifg=black  guibg=white
"  hi nontext  ctermfg=blue   ctermbg=white guifg=blue   guibg=white
" syntax coloring!! :-)
syn on
" smart search
"  set incsearch
"  set ignorecase
"  set smartcase
" set modelines
map  :set timeout=9000
set autoindent
set shiftwidth=4
set tabstop=4
set redraw
set ignorecase
set nonumber
set ai
map g $
" Cursor keys
map [216z 
map [222z 
map [214z 1G
map [220z G
map OA k
map OB j
map OD h
map OC l
" Next File F1
map [224z :n
" Write - Next File F1
map [225z :w:n
" Word completion (Komplete, Next, Previous).
"
" Eric Edward Bowles  (bowles@is.s.u-tokyo.ac.jp)
"
" Here is my set of word completion macros.  Type the first part of
" a word, then do ^K to try to complete it.  If it's not correct, keep
" on trying using ^N (for next).  If you want a previous match, use
" ^P (for previous).
:map!  a. hbmmi?\<2h"zdt.@zywmx`mPbea dwbis"zdt.x@z
:map!  a. hbmmdw`xnywmx`mPbea dwbis"zdt.x@z
:map!  a. hbmmdw`xNywmx`mPbea dwbis"zdt.x@z
:map!  #
"
" Call cb
"
map \b :%!cb
map \f :%!fmt
map \e :%!expand -t4
"
" Comment line
"
map  ^i/* A */^
" Uncooment
map  :s/\/\* \([^*]*\) \*\//\1
"
" Mark
"
map == mb
" Yank from mark
map =y :'b,.y
" Delete from mark
map =d :'b,.d
" Cb grom mark
map =b :'b,.!cb
" Write block
map =w :'b,. w! $HOME/.vitemp  
" Read bolck
map =r :r $HOME/.vitemp  
" Box from mark
map =c ^mc`bO/*========`co========*/
map =C :'b,. !cbox
"
map =t 1GO:r !title %1Gdd
"
" subsitute
map \s :1,$ s/
" Agian
map \a :1,$ sg
"Rule
map \r 0O....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+....8
"Date \d
map \d :r !echo %:r !finger $USER|grep life|cut -f3 -d:|uniq:r !date
" Get manual page
map \m byeo:!man p"zdd@z
map \g byeo:!grep -n pa %"zdd@z
map \M byeo:!hman pa& "zdd@z
" View include file
" map \i l?<ly$0o:!vi /usr/include/p^/>x"zdd@z
map \\ ^/\.hbdwuOpA_HI#ifndef jo#endif
"map! /*     /*  */hhi
map \c :!cc %
:map! # #
map @@ :!cleartool co -nc %
map \h 1G:r !viheader %1Gdd
map \c 1G:r !class %1Gdd
map \i :r !init1 %
map \j :r !init2 %
map \z i/*! \class myClass * \brief it has to be brief* \author Guillaume Aubert ECMWF* \version 0.1* \date Nov 2003** Add Class Details*/
map \a i//! describe me/*! \param myparam.\return return\sa otherclass** Add Method Details*/
map  :w:n
"map 0  :n
map \;	o//============================================================================^
" comment 2
"map  ^i//! non-blocking read. Try to read up to length bytes. \\
"/*!
" \param buffer buffer to fill.
" \param length length to read.
" \return length read.
" \sa write().
"*/A ^
set expandtab " replaces any tab keypress with the appropriate number of spaces
set tabstop=4 " sets tabs to 4 spaces
set noai
