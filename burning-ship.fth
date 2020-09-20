64 constant sx
46 constant sy
100 constant mk

( -> fp )
: aspect
sy ufloat sx ufloat f/
;

( -> fp )
: ox
-2.15
;

( -> fp )
: oy
-1.669
;

( -> fp )
: wx
3.4
;

( -> fp )
: wy
wx aspect f*
;

( -> fp )
: xf
sx ufloat wx f/
;

( -> fp )
: yf
sy ufloat wy f/
;

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

( fp1, fp2 -> fp1, fp2, fp1 )
: fover
4 pick 4 pick
;

( fp1, fp2, fp3 -> fp2, fp3, fp1 )
: frot
6 roll 6 roll
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

( x -> x )
: fabs
32767 and
;

( k x y tx ty -> k )
: burningship-iter
9 pick ( iteration number TOS )
mk >
if ( return if number if iterations is greater then mk )
  fdrop ( discard ty )
  fdrop ( discard tx )
  fdrop ( discard y pos )
  fdrop ( disacrd x pos )
  drop ( discard iteration )
  mk
  exit
then

fover ( tx' )
fover ( ty' )

fdup f* ( ty * ty )
fswap fdup f* ( tx * tx )
f+ ( tx * tx + ty + ty )
4.0 f<
if
  ( t = | tx * tx - ty * ty + x | )
  fover ( ty' )
  fover ( tx' )
  f*
  fswap
  f*
  f-
  10 pick
  10 pick ( x' )
  f+
  fabs

  ( | 2 * tx * ty + y | )
  frot
  frot
  f*
  2.0 f*
  6 pick
  6 pick ( y' )
  f+
  fabs

  ( k + 1 )
  9 roll ( k on TOS )
  1+
  9 roll 9 roll
  9 roll 9 roll
  9 roll 9 roll
  9 roll 9 roll

  burningship-iter
then

fdrop ( drop ty )
fdrop ( drop tx )
fdrop ( drop y )
fdrop ( drop x )
( return k on TOS )
;

: burningship
sy 0
do
  sx 0
  do
    i j 1 plot
    0 ( iteration number )
    i ufloat xf f/ ox f+ ( x position on argand diagram )
    sy ufloat j ufloat f- yf f/ oy f+ ( y position on argand diagram )
    fover ( tx )
    fover ( ty )
    burningship-iter
    mk <
    if
      i j 0 plot
    then
  loop
loop
;
