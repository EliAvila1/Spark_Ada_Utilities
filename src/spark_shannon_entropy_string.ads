package spark_shannon_entropy_string
with SPARK_Mode => On
is

   subtype sub_entropy       is Float   range 0.0 .. 8.0
     with Static_Predicate => sub_entropy in 0.0 .. 8.0;

   function shannon_entropy (Item : String) return sub_entropy
     with
       Pre => (Item'First = 1)
       and then (Item'Length >= 1)
       and then (Item'Length <= Long_Long_Integer'Last)
       and then (Item'Last = Item'Length)
       and then (for all chars in Item'First .. Item'Last
                   => Character'Pos(Item(chars)) in 33 .. 126),
       Post => (shannon_entropy'Result in sub_entropy),
       Global => Null;

end spark_shannon_entropy_string;
