( x -> bool )
: f0=
0 =
if
  0 =
  if
    1
    exit
  then
else
  drop
then
0
;

( x y -> bool )
: f<
f-
fdup f0=
if
  fdrop
  0
  exit
then
swap
drop
0 >
if
  0
  exit
then
1
;

( x y -> bool )
: f=
f- f0=
;

( x y -> bool )
: f>
f-
fdup f0=
if
  fdrop
  0
  exit
then
swap
drop
0 <
if
  0
  exit
then
1
;

( x -> bool )
: f0<
0.0 f<
;

( x -> bool )
: f0>
0.0 f>
;

( x -> x )
: fabs
32767 and
;

( Below is sourced from the Jupiter Ace Manual: Chapter 15 page 89 )
( fp -> )
: fdrop
drop drop
;

( fp -> fp, fp )
: fdup
over over
;

( fp1, fp2 -> fp2, fp1 )
: fswap
4 roll 4 roll
;

( fp1, fp2 -> fp1, fp2, fp1 )
: fover
4 pick 4 pick
;

( fp1, fp2, fp3 -> fp2, fp3, fp1 )
: frot
6 roll 6 roll
;

( address -> fp )
: f@
dup @ swap 2+ @
;

( fp -> address )
: f!
rot over ! 2+ 1
;
