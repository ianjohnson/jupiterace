( Open addressed hash table                                                )

0 constant new-entry
1 constant re-entry
2 constant full-soft-limit
3 constant full-hard-limit

( findword )
16 base c!

create findword df C, af C, 47 C, 1a C, 4f C, 13 C, 2a C, 33 C, 3c C, 7e C, 23 C, 66 C, 6f C, 7e C, e6 C, 3f C, 28 C, 1e C, a9 C, 20 C, 1b C, d5 C, e5 C, cd C, e8 C, 15 C, 41 C, 1a C, cd C, 07 C, 08 C, 13 C, ae C, e6 C, 7f C, 23 C, 20 C, 08 C, 10 C, f3 C, d1 C, 13 C, d7 C, d1 C, fd C, e9 C, e1 C, d1 C, 2b C, 7e C, 2b C, 6e C, 67 C, b5 C, 20 C, d5 C, c3 C, 8a C, 06 C, findword dup 2- !

decimal

: count
  dup 1+ swap c@
;

( String )
: stringify
  ascii " word count dup c,
  over + swap
  do
    i c@ c,
  loop
;

( string_addr -> [n] )
: thunk
  findword dup 0=
  if
    ." ERROR 13"
    cr
    abort
  else
    execute
  then
;

( hash_addr -> n )
: hash-no-entries
  @
;

( hash_addr -> n )
: hash-size
  2+
  @
;

( hash_addr -> n )
: hash-key-size
  4 +
  @
;

( hash_addr -> n )
: hash-value-size
  6 +
  @
;

( hash_addr -> n )
: _hash-bucket-size
  8 +
  @
;

( hash_addr -> addr of word )
: _hash-func-name
  10 +
;

( hash_addr -> addr of word )
: _hash-cmp-func-name
  _hash-func-name
  dup c@ +
  1+
;

( hash_addr -> addr )
: _hash-array-addr
  _hash-cmp-func-name
  dup c@ +
  1+
;

( hash_addr n -> addr )
: _hash-array-slot-addr
  over _hash-bucket-size * ( addr offset to slot )
  swap _hash-array-addr
  +
;

( slot_addr -> user_slot_addr )
: _hash-array-slot-user-addr
  1+
;

( hash_addr key -> bucket_index )
: hash-find-slot
  over over                      ( hash_addr key hash_addr key )
  swap                           ( hash_addr key key hash_addr )
  _hash-func-name thunk abs      ( hash_addr key hash )
  3 pick                         ( hash_addr key hash hash_addr )
  hash-size                      ( hash_addr key hash hash_size )
  mod                            ( hash_addr key bucket_index )
  begin
    dup                          ( hash_addr key bucket_index bucket_index )
    4 pick                       ( hash_addr key bucket_index bucket_index hash_addr )
    swap                         ( hash_addr key bucket_index hash_addr bucket_index )
    _hash-array-slot-addr dup    ( hash_addr key bucket_index bucket_addr bucket_addr )
    c@                           ( hash_addr key bucket_index bucket_addr occupied_flag )
    1 and                        ( hash_addr key bucket_index bucket_addr masked_occupied_flag )
    if                           ( hash_addr key bucket_index bucket_addr )
      ( Slot user data is after the byte flag )
      _hash-array-slot-user-addr ( hash_addr key bucket_index bucket_addr )
      3 pick swap                ( hash_addr key bucket_index key bucket_addr )
      5 pick                     ( hash_addr key bucket_index key bucket_addr hash_addr )
      _hash-cmp-func-name thunk  ( hash_addr key bucket_index key_cmp_flag )
    else
      drop                       ( hash_addr key bucket_index )
      0
    then
  while
    1+
    3 pick hash-size mod
  repeat  
                                 ( hash_addr key bucket_index )
  rot drop                       ( key bucket_index )
  swap drop                      ( bucket_index )
;

( hash_addr key -> user_slot_value_addr )
: hash-lookup
  over over                             ( hash_addr key hash_addr key )
  hash-find-slot                        ( hash_addr key bucket_index )
  3 pick swap _hash-array-slot-addr dup ( hash_addr key slot_addr slot_addr )
  c@ 1 and
  if                                    ( hash_addr key slot_addr )
    ( slot is occupied, i.e. found )
    _hash-array-slot-user-addr
    ( Return the slot's value addr )
    rot hash-key-size +                 ( key user_slot_value_addr )
    swap drop                           ( user_slot_value_addr )
  else
    ( not found )
    drop drop drop
    0
  then
;

( hash_addr key -> [user_slot_addrs] set_result                               )
( If set_result = new-entry or full-soft-limit                                ) 
(   then user_slot_value_addr user_slot_key_addr set_result                   )
( If set_result = re-entry then value address is in TOS - 1,                  )
( If set_result = full-hard-limit then no address                             )
: hash-set
  over over                    ( hash_addr key hash_addr key )
  hash-find-slot               ( hash_addr key bucket_index )
  3 pick swap                  ( hash_addr key hash_addr bucket_index )
  _hash-array-slot-addr dup    ( hash_addr key slot_addr slot_addr )
  c@ 1 and                     ( hash_addr key slot_addr occupied_flag )
  if
    ( slot is occupied, overwrite the value )
    _hash-array-slot-user-addr ( hash_addr key slot_key_addr )
    rot hash-key-size +        ( hash_addr key slot_value_addr )
    swap drop
    re-entry
    exit
  then

  3 pick dup                   ( hash_addr key slot_addr hash_addr hash_addr )
  hash-no-entries swap hash-size =
  if
    drop drop drop
    full-hard-limit
    exit
  then                         ( hash_addr key slot_addr )

  ( increment the number of entries )
  3 pick dup @ 1+ swap !

  ( set slot to occupied )
  dup 255 swap c!

  _hash-array-slot-user-addr  ( hash_addr key user_slot_addr )
  dup 4 pick hash-key-size +  ( hash_addr key user_slot_key_addr user_slot_value_addr )
  swap                        ( hash_addr key user_slot_value_addr user_slot_key_addr )

  ( Recommended to keep load factor under 70% )
  4 roll dup hash-no-entries swap hash-size 7 * 10 / > ( key user_slot_value_addr user_slot_key_addr )
  if
    rot drop
    full-soft-limit
  else
    rot drop
    new-entry
  then
;

( hash_addr -> hash_addr )
: hash-initialise
  0 over !
  dup hash-size 0
  ( Initialise the occupied flags in the bucket array )
  do
    dup i _hash-array-slot-addr 0 swap c!
  loop
;

( Open address hash table definer                                          )
( Arguments:                                                               )
(  - size = maximum number of buckets                                      )
(  - key_size = the size of the key in cells                               )
(  - value_size = the size of the value in cells                           )
(  - hash_func_name = Name, string, of the word used to calculate the hash )
(                     value                                                )
(  - cmp_func_name = Name, stirng, of the word used to compare a key       )
(                                                                          )
( Usage:                                                                   )
(   200 1 1 hashtable ht [hash word name]"[key compare word name]"         )
(                                                                          )
( Parameter field:                                                         )
(  - Number of entries MUST BE FIRST                                       )
(  - Maximum number of entries                                             )
(  - Key maximum size in bytes                                             )
(  - Value maximum size in bytes                                           )
(  - Key comparator word address                                           )
(  - Hash value word address                                               )
(  - Bucket size in bytes                                                  )
(  - Bucket array                                                          )
(                                                                          )
( Bucket slot has format:                                                  )
(  - Occupied byte (0 - unoccpied, non zero - occupied                     )
(  - Key                                                                   )
(  - Value                                                                 )
definer hashtable
  ( size key_size value_size )
  0 , ( no entries in hash table )
  3 pick , ( size of hash table )
  2 pick , ( key size in bytes )
  dup , ( value size in bytes )
  + 1+ dup , ( bucket size in bytes, including occupied flag )
  stringify ( hash func name )
  stringify ( cmp func name )
  * ( size of collision list in bytes )
  allot
does>
;
