with Interfaces.C;

with DataType_Win32;
with spark_bcryptgenrandom;

package body spark_generate_entropy
with SPARK_Mode => On
is

   use Interfaces.C;

   function bytes_max (Len : in Positive) return Need_Function
     with Pre => (Len >= 1) and then (Len <= Positive'Last),
     Post => (Case Len is
                when 1 .. 500 => bytes_max'Result = 250,
                  when 501 .. 1000 => bytes_max'Result = 500,
                    when 1001 .. 2500 => bytes_max'Result = 1000,
                      when 2501 .. 5000 => bytes_max'Result = 2000,
                        when 5001 .. 7500 => bytes_max'Result = 3000,
                          when 7501 .. 10000 => bytes_max'Result = 5000,
                            when others => bytes_max'Result = 5000),
                 Global => Null
   is
   begin
      Case Len is
         when 1 .. 500 =>
            return R_1;
         when 501 .. 1000 =>
            return R_2;
         when 1001 .. 2500 =>
            return R_3;
         when 2501 .. 5000 =>
            return R_4;
         when 5001 .. 7500 =>
            return R_5;
         when 7501 .. 10000 =>
            return R_6;
         when others =>
            return R_7;
      end case;

   end bytes_max;


   procedure full_mixed_entropy (Item  : in out Str_Mix_Ent;
                                 Woks  : out Boolean) is

      subtype unbiased_full is Interfaces.C.unsigned_char range 0 .. 239;
      charset_mixed : constant string(1 .. 80) :=
        "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%&()[]{}|/\<>?";


      Need   : Constant Need_Function := bytes_max(Len => Positive(Item'Length));
      Length : constant Array_Len_Byt := (Need + Item'Length);

      Bytes  : spark_bcryptgenrandom.BC_Array(1 .. Length) := (others => 0);
      Status : Boolean;

      Bytes_Counter     : Natural range 0 .. Bytes'Length  := 0;
      Bytes_Counter_Max : Positive range Bytes'Length .. Bytes'Length := Bytes'Length;

      Item_Counter      : Natural range 0 .. Item'Length   := 0;
      Item_Counter_Max  : Positive range Item'Length .. Item'Length := Item'Length;

      Save_While : Str_Mix_Ent(1 .. Item'Length) := (others => '0');

   begin

      ---
      spark_bcryptgenrandom.wrapper_bcrypt(Item => Bytes,
                                           Woks => Status);

      if Status then

         if spark_bcryptgenrandom.bcrypt_entropy
           (Item => Bytes) not in 6.5 .. 8.0 then

            Item := (others => '0');
            Woks := False;
            return;

         end if;

      else

         Item := (others => '0');
         Woks := False;
         return;

      end if;
      ---

      Main_Loop:
      for C in 1 .. 2 loop
         pragma Loop_Variant   (Increases => C);
         pragma Loop_Invariant (C in 1 .. 2);


         Fill_loop:
         while Item_Counter < Item_Counter_Max
           and then Bytes_Counter < Bytes_Counter_Max loop

            pragma Loop_Variant   (Increases => Bytes_Counter);
            pragma Loop_Invariant (Bytes_Counter in 0 .. Bytes'Length);
            pragma Loop_Invariant (Item_Counter in 0 .. Item'Length);

            Bytes_Counter := Bytes_Counter + 1;

            if Bytes(Bytes_Counter) in unbiased_full then
               Item_Counter := Item_Counter + 1;

               pragma Assert ((Natural(Bytes(Bytes_Counter) mod 80) + 1) in 1 .. 80);
               Save_While(Item_Counter) := charset_mixed((Natural(Bytes(Bytes_Counter) mod 80) + 1));

            end if;

         end loop Fill_loop;

         exit Main_Loop when Item_Counter = Item'Length;

         if Bytes_Counter >= Bytes_Counter_Max - 2
           and then Item_Counter < Item_Counter_Max then

            Bytes_Counter := 0;

            spark_bcryptgenrandom.SecureZeroMemory
              (Pvoid  => Bytes,
               Size_T => DataType_Win32.ULONG (Bytes'Length));

            Bytes         := (others => 0);

            spark_bcryptgenrandom.wrapper_bcrypt(Item => Bytes,
                                                 Woks => Status);

            if Status then

               if spark_bcryptgenrandom.bcrypt_entropy
                 (Item => Bytes) not in 6.5 .. 8.0 then

                  Save_While := (others => '0');
                  Item := (others => '0');
                  Woks := False;
                  return;

               end if;

            else

               Save_While := (others => '0');
               Item := (others => '0');
               Woks := False;
               return;

            end if;

         end if;

      end loop Main_Loop;

      spark_bcryptgenrandom.SecureZeroMemory
        (Pvoid  => Bytes,
         Size_T => DataType_Win32.ULONG (Bytes'Length));

      Bytes         := (others => 0);
      Bytes_Counter := 0;

      if Item_Counter = Item'Length then
         Item       := Save_While;
         Save_While := (others => '0');
         Woks       := True;
      else
         Save_While := (others => '0');
         Item := (others => '0');
         Woks := False;
      end if;


   end full_mixed_entropy;

end spark_generate_entropy;

