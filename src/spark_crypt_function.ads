package spark_crypt_function
with SPARK_Mode => On
is

   subtype mxb is Positive range 256 .. 256;
   max_byte : constant mxb := 256;

   subtype div is Positive range 1 .. 256
     with Static_Predicate => div in 1 .. 256;

   function division (Len : in Positive) return div
     with Pre => (Len >= 1) and then (Len <= 256),
     Post => division'Result = div(max_byte / Len),
     Global => Null;

   --------

   subtype ses is Positive range 128 .. 255
     with Static_Predicate => ses in 128 .. 255;

   function sesgo (Unb : in Positive) return ses
     with Pre => (Unb >= 1 ) and then (Unb <= 256),
     Post => sesgo'Result = ses(Unb * division(Len => Unb) - 1),
     Global => Null;

   --------

   subtype rej is Positive range 1 .. 128
     with Static_Predicate => rej in 1 .. 128;

   function reject (Vod : in Positive) return rej
     with Pre => (Vod >= 128) and then (Vod <= 255),
     Post => reject'Result = rej(max_byte - Vod),
     Global => Null;

   --------

   subtype per is Float    range 0.39 .. 50.00
     with Static_Predicate => per in 0.39 .. 50.00;

   function Percent (Trh : in Positive) return per
     with Pre => (Trh >= 1) and then (Trh <= 128),
     Post => Percent'Result = per(Float'Min(50.00, Float'Max(0.39,
                                  (Float(Trh) / Float(max_byte)) * 100.0)));

   --------

   function Is_Pure_Chain (Item_Chain : in String) return Boolean
     with Pre => (Item_Chain'First = 1)
     and then (Item_Chain'Length >= 10)
     and then (Item_Chain'Length <= 94)
     and then (Item_Chain'Last = Item_Chain'Length)
     and then (for all C in Item_Chain'Range =>
                 Character'Pos(Item_Chain(C)) in 33 .. 126),
     Global => Null;

end spark_crypt_function;
