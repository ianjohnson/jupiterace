# Open Addressed Hash Table
This is an implementation of a hash table written in Forth and a few bytes of Z80. It uses [open addressing](https://en.wikipedia.org/wiki/Open_addressing) which has a number of drawbacks but allows the whole hash table to be easily embedded in a Forth word using `definer`.

## Finding Words in Forth Words
The hash table implementation uses _callbacks_ to generate hash values and hash value comparisons. This allow users to store any type of data in the hash table. Two words are required that generate hash values and key comparisons, and the _name_ of these words are stored in the hash table as strings. When the implementation requires these words the Z80 code is called, to search for the compilation addresses, and the words' addresses are used to execute them. Since the Jupiter Ace can change a word's compilation address during compilation of other words this method of _delayed dispatch_ seems the only method to use. 

A Z80 routine is required since the `find` word on the Jupiter Ace does not work as expected when called from a Forth word. The Z80 emulates the ROM routine for `find` but can be called from in a word, and will return the correct compilation address of a Forth word if it exists. The Z80 routine will add a 0 to TOS if the searched word does not exist, otherwise the compilation address of the word is on TOS. The Z80 routine is relocatable, so you can choose where you store this routine. However the constant `findword` in the Forth code will need to be changed.

## Creating a Hash Table
The following information is required to create a hash table:
* Size: the maximum number of entries in the hash table,
* Key size: the size, in bytes, of the key,
* Value size: the size, in bytes, of the value,
* Hash word name: the name of the word that will calculate the hash value for a key, and
* Key comparison word name: the name of the word that will compare keys.

The hash word has the signature `( key_value -> n )`, the key is on TOS and the word should replace this value with a hash value for the key. For keys of type integer this word can be just `: khw ;`.

The key comparison word has the signature `( key_value stored_key_addr -> n )`, if the keys are equal `n` should be `0`, otherwise non-zero. For keys of type integer this word can look like `: kcw @ = if 0 else 1 then ;`.

For example, for a hash table of size 200 and keys and values of type integer can be created using:
```forth
200 2 2 hashtable ht khw"kcw"
```

## Loading Hash Table
The Z80 `findword` routine can be loaded anywhere in memory. For example,
```
( Set RAM top )
65000 15384 ! quit
65000 59 bload fndwrd.bin
load ht.fth
```

The constant `findword` should be altered in the Forth code if the Z80 routine is placed anywhere else in memory.

## Hash Table Usage
A few examples of the usage of the hash table are shown below.

### Character Keys and Values
```forth
( c -> n )
: chf
;

( c key_addr -> n )
: chcf
  c@ =
  if
    0
  else
    1
  then
;

100 1 1 hashtable ht chf"chcf"

( Insert a key/value )
ht ascii A hash-set .       ( 0 is a new entry )
ascii A swap c!             ( Store the key )
ascii Z swap c!             ( Store the value )

( Lookup a value )
ht ascii A hash-lookup
c@ emit                     ( Displays 'Z' )

( Re-insert key/value )
ht ascii A hash-set .       ( 1 is a re-entry )
ascii Q swap c!             ( Store new value )

( Lookup new value )
ht ascii A hash-lookup
c@ emit                     ( Displays 'Q' )
```

### Integer/Pointer Keys and Values
```forth
( n -> n )
: hf
;

( n key_addr -> n )
: hcf
  @ =
  if
    0
  else
    1
  then
;

100 2 2 hashtable ht hf"hcf"

( Insert a key/value )
ht 7 hash-set .             ( 0 is a new entry )
7 swap !                    ( Store the key )
667 swap !                  ( Store the value )

( Lookup a value )
ht 7 hash-lookup
@ .                         ( Displays '667' )

( Re-insert a key/value )
ht 7 hash-set .             ( 1 is re-entry )
1023 swap !                 ( Store new value )

( Lookup new value )
ht 7 hash-lookup
@ .                         ( Displays '1023' )
```

### String Keys and Integer/Pointer Values
```forth
( key_addr -> n )
: shf
  0                         ( key_addr hv )
  over 1+                   ( key_addr hv sos_addr )
  rot                       ( hv sos_addr key_addr )
  c@                        ( hv sos_addr string_length )
  over +                    ( hv sos_addr eos_addr )
  swap                      ( hv eos_addr sos_addr )
  do
    i c@ + 13 * 
  loop
;

( key_addr bucket_key_addr -> n )
: shcf
  over c@ over c@ =
  if
    ( Equal string lengths )
    dup c@                  ( key_addr bucket_key_addr length )
    rot 1+                  ( bucket_key_addr length key_sos_addr )
    rot 1+                  ( length key_sos_addr bucket_key_sos_addr )
    begin
      over c@ over c@ =
      if
        ( Characters match )
	rot 1-              ( key_sos_addr bucket_key_sos_addr new_length )
	dup 0=
	if
	  ( String match )
	  drop drop drop
	  ( Comparison result is equals )
	  0
	  ( End loop )
	  1
	else
	  rot 1+            ( bucket_key_sos_addr new_length new_key_sos_addr )
	  rot 1+            ( new_length new_key_sos_addr new_bucket_key_sos_addr )
	  0
	then
      else
        ( Characters do not match )
        drop drop drop
	( Comparison result is not equals )
        1
	( End Loop )
	1
      then
    until
  else
    drop drop
    1
  then
;

( dest_string src_string -> )
: string-copy
  dup c@ dup                ( dest_string src_string length length )
  4 pick                    ( dest_string src_string length length dest_string )
  ( Copy length )
  c!                        ( dest_string src_string length )
  ( Copy string )
  rot 1+                    ( src_string length dest_string )
  rot 1+                    ( length dest_string src_string )
  begin
    dup c@                  ( length dest_string src_string char )
    3 pick c!               ( length dest_string src_string )
    rot 1-                  ( dest_string src_string new_length )
    dup 0=
    if                      ( dest_string src_string new_length )
      drop drop drop
      1
    else
      rot 1+                ( src_string new_length new_dest_string )
      rot 1+                ( new_length new_dest_string new_src_string )
      0
    then
  until
;

definer string
  stringify
does>
;

100 4 2 hashtable ht shf"shcf"

( Create some strings )
string one one"

( Insert key/value )
ht one hash-set .           ( 0 is a new entry )
one string-copy             ( Store the key )
1 swap !                    ( Store the value )

( Lookup value )
ht one hash-lookup
@ .                         ( Displays '1' )

( Re-insert key/value )
ht one hash-set             ( 1 is a re-entry )
11 swap !                   ( Store the new value )

( Lookup new value )
ht one hash-lookup
@ .                         ( Displays '11' )
```
