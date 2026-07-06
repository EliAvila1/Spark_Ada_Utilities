with Ada.Real_Time;

package spark_generate_entropy
with SPARK_Mode => On
is

   subtype Str_Mix_Ent is string
     with Dynamic_Predicate => Str_Mix_Ent'First = 1
     and then Str_Mix_Ent'Length >= 1
     and then Str_Mix_Ent'Last = Str_Mix_Ent'Length
     and then   (for all M in Str_Mix_Ent'First .. Str_Mix_Ent'Last
                 => Str_Mix_Ent(M) in '0' .. '9' or
                     Str_Mix_Ent(M) in 'A' .. 'Z' or
                     Str_Mix_Ent(M) in 'a' .. 'z' or
                     Str_Mix_Ent(M) in '!' .. '!' or
                     Str_Mix_Ent(M) in '>' .. '@' or
                     Str_Mix_Ent(M) in '#' .. '&' or
                     Str_Mix_Ent(M) in '(' .. ')' or
                     Str_Mix_Ent(M) in '[' .. ']' or
                     Str_Mix_Ent(M) in '{' .. '}' or
                     Str_Mix_Ent(M) in '/' .. '/' or
                     Str_Mix_Ent(M) in '<' .. '<');



   procedure full_mixed_entropy (Item  : in out Str_Mix_Ent;
                                 Woks  : out Boolean)
     with Pre => (for all I in Item'First .. Item'Last
                  => Item(I) in '0' .. '0')
     and then (Item'First = 1)
     and then (Item'Length >= 1)
     and then (Item'Length <= 10_000)
     and then (Item'Last = Item'Length),

     Post => (if Woks then
                (for all I in Item'First .. Item'Last
                 => Item(I) in '0' .. '9' or
                    Item(I) in 'A' .. 'Z' or
                    Item(I) in 'a' .. 'z' or
                    Item(I) in '!' .. '!' or
                    Item(I) in '>' .. '@' or
                    Item(I) in '#' .. '&' or
                    Item(I) in '(' .. ')' or
                    Item(I) in '[' .. ']' or
                    Item(I) in '{' .. '}' or
                    Item(I) in '/' .. '/' or
                    Item(I) in '<' .. '<')
                  else
                (for all I in Item'First .. Item'Last
                 => Item(I) in '0' .. '0')),

     Depends => (Item => Item,
                 Woks => Item,
                 null => Ada.Real_Time.Clock_Time),
     Global => (Input => Ada.Real_Time.Clock_Time);

private

   subtype Array_Len_Byt is Positive range 251 .. 15_000;
   subtype Need_Function is Positive range 250 .. 5000;
   subtype Need_1        is Positive range 250 .. 250;
   subtype Need_2        is Positive range 500 .. 500;
   subtype Need_3        is Positive range 1000 .. 1000;
   subtype Need_4        is Positive range 2000 .. 2000;
   subtype Need_5        is Positive range 3000 .. 3000;
   subtype Need_6        is Positive range 5000 .. 5000;
   subtype Need_7        is Positive range 5000 .. 5000;

   R_1 : constant Need_1 := 250;
   R_2 : constant Need_2 := 500;
   R_3 : constant Need_3 := 1000;
   R_4 : constant Need_4 := 2000;
   R_5 : constant Need_5 := 3000;
   R_6 : constant Need_6 := 5000;
   R_7 : constant Need_7 := 5000;

end spark_generate_entropy;
