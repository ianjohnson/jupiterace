64.0 constant sx
46.0 constant sy
sy sx f/ constant aspect
-2.15 constant ox
-1.669 constant oy
3.4 constant wx
wx aspect f* constant wy
100 constant mk
sx wx f/ constant xf
sy wy f/ constant yf

( fp -> fp, fp )
: fdup
over over
;

( fp -> )
: fdrop
drop drop
;

( fp1, fp2 -> fp2, fp1 )
: fswap
4 roll 4 roll
;

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

( x -> x )
: fabs
32767 and
;

: burningship
sy int 0
do
  sx int 0
  do
    i j 1 plot
    0 ( iteration number )
    i ufloat xf f/ ox f+ ( x position on argand diagram )
    sy j f- yf f/ oy f+ ( y position on argand diagram )
    burningship-iter
    mk <
    if
      i j 0 plot
    then
  loop
loop
;

( k x y -> k )
: burningship-iter
2 pick ( x' )
2 pick ( y' )
5 pick ( iteration number TOS )
mk >
if ( return if number if iterations is greater then mk )
  drop ( discard y pos )
  drop ( disacrd x pos )
  drop ( discard iteration )
  mk
  exit
then

dup f* ( y * y )
swap dup f* ( x * x )
f+ ( x * x + y + y )
4.0 f>
if
  drop
  drop
  ( return k on TOS )
then

rot 1+

dup f*
;

