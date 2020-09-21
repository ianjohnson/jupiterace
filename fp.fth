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

( Missing floating point operator implementations )
( fp -> flag ; True if fp = 0.0 )
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

( fp1 fp2 -> flag ; True if fp1 < fp2 )
: f<
f-
fdup f0=
if
  fdrop
  0
else
  swap
  drop
  0 >
  if
    0
  else
    1
  then
then
;

( fp1 fp2 -> flag ; True if fp1 = fp2 )
: f=
f- f0=
;

( fp1 fp2 -> flag ; True if fp1 > fp2 )
: f>
f-
fdup f0=
if
  fdrop
  0
else
  swap
  drop
  0 <
  if
    0
  else
    1
  then
then
;

( fp -> flag ; True if fp < 0.0 )
: f0<
0.0 f<
;

( fp -> flag ; True if fp > 0.0 )
: f0>
0.0 f>
;

( fp1 -> fp2 ; fp2 = |fp1| )
: fabs
32767 and
;

( fp1 fp2 -> fp3 ; Leave greater of two numbers )
: fmax
fover
fover
f>
if
  fdrop
else
  fswap
  fdrop
then
;

( fp1 fp2 -> fp3 ; Leave lesser of the two numbers )
: fmin
fover
fover
f<
if
  fdrop
else
  fswap
  fdrop
then
;

