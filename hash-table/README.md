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
hash-initialise

( Insert a key/value )
ascii A hash-set .          ( 0 is a new entry )
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
hash-initialise

( Insert a key/value )
7 hash-set .                ( 0 is a new entry )
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

### String Keys and Integer Values
```forth
: shf
  dup dup @ +
;

: shcf
;

100 2 1 hashtable ht shf"shcf"
hash-initialise


```