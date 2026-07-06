package spark_handling_lowercase
with SPARK_Mode => On
is

   procedure lowercase (Item : in out String)
     with Pre => (Item'First = 1)
     and then (Item'Length >= 1)
     and then (Item'Last = Item'Length)
     and then (Item'Length <= 100_000),

     Post => (for all I in Item'First .. Item'Last =>
                (if Character'Pos(Item'Old(I)) in 65 .. 90
                     then Character'Pos(Item(I)) = Character'Pos(Item'Old(I)) + 32
                   else Item(I) = Item'Old(I))),
     Global => Null,
     Depends => (Item => Item);

end spark_handling_lowercase;
