-- To verify change [pbBuffer : in out BC_Array] => [pbBuffer : in BC_Array]
-- Comment ........ [ -- pbBuffer =>+ (hAlgorithm, cbBuffer, dwFlags)); ]

with Ada.Numerics.Elementary_Functions;
with System;

package body spark_bcryptgenrandom
with SPARK_Mode => On
is
   --==============--
   --== INTERNAL ==--
   --==============--

   function BCryptGenRandom (hAlgorithm : in HANDLE := System.Null_Address;
                             pbBuffer   : in BC_Array;
                             cbBuffer   : in ULONG;
                             dwFlags    : in ULONG := BCRYPT_USE_SYSTEM_PREFERRED_RNG)
                             return NTSTATUS
     with
       Import      => True,
       Convention  => Stdcall,
       Link_Name   => "BCryptGenRandom",

       Pre         => (pbBuffer'First = 1)
       and then (pbBuffer'Last = pbBuffer'Length),

       Post        => (if BCryptGenRandom'Result = STATUS_SUCCESS then
                         (for all M in pbBuffer'First .. pbBuffer'Last
                          => pbBuffer(M) in 0 .. 255)
                           else
                         (for all M in pbBuffer'First .. pbBuffer'Last
                          => pbBuffer(M) in 0 .. 0)),

       Global      => null,

       Depends     => (BCryptGenRandom'Result => (hAlgorithm, pbBuffer, cbBuffer, dwFlags));
             --          pbBuffer =>+ (hAlgorithm, cbBuffer, dwFlags));

   --===============--
   --== PUBLIC    ==--
   --===============--

   procedure wrapper_bcrypt (Item : in out BC_Array;
                             Woks : out Boolean) is
      status : NTSTATUS;
   begin
      Woks := False;

      for I in reverse 1 .. 5 loop

         pragma Loop_Variant   (Decreases => I);
         pragma Loop_Invariant (I in 1 .. 5);

         status := BCryptGenRandom(pbBuffer => Item,
                                   cbBuffer => ULONG (Item'Length));

         exit when status = STATUS_SUCCESS;

         SecureZeroMemory(Pvoid  => Item,
                          Size_T => ULONG (Item'Length));

         Item := (others => 0);

         if I <= 1 then

            SecureZeroMemory(Pvoid  => Item,
                             Size_T => ULONG (Item'Length));

            Item := (others => 0);
            Woks := False;
            return;
         end if;

         delay 1.5;

      end loop;

      if status = STATUS_SUCCESS then
         Woks := True;
      end if;

   end wrapper_bcrypt;


   function bcrypt_entropy (Item : BC_Array) return sub_entropy is

      subtype counter_array_nat is Natural
      range 0 .. Natural(Item'Length);

      subtype item_legth_int    is Positive range
        Positive(Item'Length) .. Positive(Item'Length);

      subtype sub_frequency      is Float   range 0.0002 .. 1.0
        with Static_Predicate => sub_frequency in 0.0002 .. 1.0;

      type Counter_Array is array (Interfaces.C.unsigned_char'(0)
                                   .. Interfaces.C.unsigned_char'(255))
        of counter_array_nat;
      Counter : Counter_Array := (others => 0);

      frequency    : sub_frequency;
      entropy      : sub_entropy             := 0.0;
      item_Length  : Constant item_legth_int := Item'Length;

      function Division (Nat : in Natural) return Float
        with
          Pre => (Nat > 0) and then (Nat <= Natural(item_Length)),
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
                                <= Natural(I - Item'First));

         pragma Loop_Invariant (Counter(Item(I))
                                <= Natural(item_Length));

         Counter(Item(I)) := Counter(Item(I)) + 1;

      end loop;

      for I in Counter'First .. Counter'Last loop

         pragma Loop_Variant (Increases => I);

         if Counter(I) > 0 then
            frequency := Division(Nat => Counter(I));
            entropy := Float'Min (Float'Max (entropy -
                                  (frequency * Shannon(Pat => frequency)),
                                  0.0), 8.0);
         end if;

      end loop;

      return sub_entropy(entropy);
   end bcrypt_entropy;

end spark_bcryptgenrandom;
