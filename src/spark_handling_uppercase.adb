package body spark_handling_uppercase
with SPARK_Mode => On
is

   procedure uppercase (Item : in out String) is

      subtype to_sum     is Positive range 32 .. 32;
      subtype to_int_str is string(Item'First .. Item'Last);

      subtype conversion is Positive range 97 .. 122
        with Static_Predicate => conversion in 97 .. 122;

      subtype added is Positive range 65 .. 90
        with Static_Predicate => added in 65 .. 90;

      char_pos : conversion := 97;
      char_sum : added;

      added_subs    : constant to_sum     := 32;
      Item_Inicial : constant to_int_str := Item;

   begin

      for I in Item'First .. Item'Last loop

         pragma Loop_Variant   (Increases => I);
         pragma Loop_Invariant (I in Item'First .. Item'Last);

         pragma Loop_Invariant (for all K in Item'First .. I - 1 =>
                                  (if Character'Pos(Item_Inicial(K)) in conversion
                                   then Character'Pos(Item(K)) = Character'Pos(Item_Inicial(K)) - added_subs
                                   else Item(K) = Item_Inicial(K)));

         pragma Loop_Invariant (for all K in I .. Item'Last =>
                                  Item(K) = Item_Inicial(K));


         if Character'Pos(Item(I)) in conversion then

            case char_pos is
               when conversion =>

                  char_pos := Character'Pos(Item(I));
                  char_sum := char_pos - added_subs;

                  if char_sum in added then
                     Item(I)  := Character'Val(char_sum);
                  end if;
            end case;

         end if;

      end loop;

   end uppercase;

end spark_handling_uppercase;
