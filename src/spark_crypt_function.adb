package body spark_crypt_function
with SPARK_Mode => On
is

   function division (Len : in Positive) return div is
     (div(max_byte / Len));

   function sesgo (Unb : in Positive) return ses is
     (ses(Unb * division(Len => Unb) - 1));

   function reject (Vod : in Positive) return rej is
     (rej(max_byte - Vod));

   function Percent (Trh : in Positive) return per is
     (per(Float'Min(50.00, Float'Max(0.39,
      (Float(Trh) / Float(max_byte)) * 100.0))));


   function Is_Pure_Chain (Item_Chain : in String) return Boolean is

      subtype array_pos   is Positive range 33 .. 126;
      type pure_chain is array (array_pos) of Long_Long_Integer;
      pure_array : pure_chain := (others => 0);

      subtype conversion is Positive range 33 .. 126
        with Static_Predicate=> conversion in 33 .. 126;

      pure_conversion : conversion := 33;

   begin

      for I in Item_Chain'First .. Item_Chain'Last loop

         pragma Loop_Variant   (Increases => I);
         pragma Loop_Invariant (pure_conversion in 33 .. 126);
         pragma Loop_Invariant

           (for all K in pure_array'Range =>
              pure_array(K) <= Long_Long_Integer(I - Item_Chain'First));

         pure_conversion := Character'Pos(Item_Chain(I));

         case pure_conversion is
            when conversion =>
               pure_array(pure_conversion) := pure_array(pure_conversion) + 1;
         end case;

      end loop;

      for Pur in pure_array'Range loop
         pragma Loop_Variant (Increases => Pur);

         if pure_array(Pur) > 1  then
            return False;
         end if;
      end loop;

      return True;

   end Is_Pure_Chain;

end spark_crypt_function;
