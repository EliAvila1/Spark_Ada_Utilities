with Ada.Numerics.Elementary_Functions;

package body spark_shannon_entropy_string
with SPARK_Mode => On
is

   function shannon_entropy (Item : String) return sub_entropy is

      subtype counter_array_nat is Long_Long_Integer
      range 0 .. Long_Long_Integer(Item'Length);

      subtype item_legth_int    is Positive range
        Positive(Item'Length) .. Positive(Item'Length);

      subtype sub_frequency      is Float   range 0.0002 .. 1.0
        with Static_Predicate => sub_frequency in 0.0002 .. 1.0;

      type Counter_Array is array (33 .. 126) of counter_array_nat;
      Counter : Counter_Array := (others => 0);

      frequency    : sub_frequency;
      entropy      : sub_entropy             := 0.0;
      item_Length  : Constant item_legth_int := Item'Length;

      function Division (Nat : in Long_Long_Integer) return Float
        with
          Pre => (item_Length >= 1)
          and then (Nat > 0)
          and then (Nat <= Long_Long_Integer(item_Length)),
        Post => Division'Result =
          (Float'Min (Float'Max (Float (Nat)
           / Float (item_Length), 0.0002), 1.0))
      is
      begin
         return (Float'Min (Float'Max (Float (Nat)
                 / Float (item_Length), 0.0002), 1.0));
      end Division;

      function Shannon (Pat : in Float) return Float
        with
          Pre  => (Pat >= 0.0002) and then (Pat <= 1.0),
        Post => Shannon'Result >= -12.3 and then Shannon'Result <= 0.0
      is
         Log_E  : constant Float :=
           Float'Min
             (Float'Max
                (Ada.Numerics.Elementary_Functions.Log(X => Pat), -8.6), 0.0);
         Log_B2 : constant Float := Log_E * 1.44269504;
      begin
         return (Float'Min (Float'Max (Log_B2, -12.3), 0.0));
      end Shannon;


   begin

      for I in Item'First .. Item'Last loop

         pragma Loop_Variant   (Increases => I);
         pragma Loop_Invariant (I in Item'First .. Item'Last);

         pragma Loop_Invariant (for all J in Counter'Range =>
                                  Counter(J)
                                <= Long_Long_Integer(I - Item'First));

         pragma Loop_Invariant (Counter(Character'Pos(Item(I)))
                                <= Long_Long_Integer(item_Length));

         Counter(Character'Pos(Item(I))) := Counter(Character'Pos(Item(I))) + 1;

      end loop;

      for I in Counter'First .. Counter'Last loop

         pragma Loop_Variant (Increases => I);

         if Counter(I) > 0 then
            frequency := Division(Nat => Counter(I));
            entropy := Float'Min (Float'Max (entropy - (frequency * Shannon(Pat => frequency)), 0.0), 8.0);
         end if;

      end loop;

      return sub_entropy(entropy);
   end Shannon_Entropy;

end spark_shannon_entropy_string;
