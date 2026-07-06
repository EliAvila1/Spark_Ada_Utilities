with Interfaces.C;
with Ada.Real_Time;
with DataType_Win32;

package spark_bcryptgenrandom
with SPARK_Mode => On
is
   use Interfaces.C;
   use DataType_Win32;

   -- Bytes(1 .. 8)     => Entropy => 2.9 .. 3.1
   -- Bytes(1 .. 16)    => Entropy => 3.6 .. 4.1
   -- Bytes(1 .. 32)    => Entropy => 4.5 .. 5.0
   -- Bytes(1 .. 64)    => Entropy => 5.5 .. 6.0
   -- Bytes(1 .. 128)   => Entropy => 6.2 .. 6.8
   -- Bytes(1 .. 256)   => Entropy => 6.9 .. 7.4
   -- Bytes(1 .. 512)   => Entropy => 7.4 .. 7.7
   -- Bytes(1 .. 1024)  => Entropy => 7.7 .. 7.9
   -- Bytes(1 .. 2024)  => Entropy => 7.7 .. 7.9
   -- Bytes(1 .. 4028)  => Entropy => 7.8 .. 8.0
   -- Bytes(1 .. 8056)  => Entropy => 7.9 .. 8.0

   -- Bytes(1 .. >= 10_000 .. <= 1_000_000) => Entropy => 7.9 .. 8.0

   subtype sub_entropy       is Float   range 0.0 .. 8.0
     with Static_Predicate => sub_entropy in 0.0 .. 8.0;

   type BC_Array is array(Positive range <>) of UCHAR
     with Convention => C;

   procedure wrapper_bcrypt (Item : in out BC_Array;
                             Woks : out Boolean )
     with
       Pre =>
         (Item'Length > 0)
         and then (Item'First = 1)
         and then (Item'Length <= 1_000_000)
         and then (Item'Last = Item'Length)
         and then (for all Byte in Item'First .. Item'Last
                   => Item(byte) in 0 .. 0),
         Post =>
           (if Woks then
              (for all Byte in Item'First .. Item'Last
               => Item(byte) in 0 .. 255)
                else
              (for all Byte in Item'First .. Item'Last
               => Item(byte) = Item'Old(byte))),

           Depends => (Item => Item,
                       Woks => Item,
                       null => Ada.Real_Time.Clock_Time),
           Global => (Input => Ada.Real_Time.Clock_Time);

   function bcrypt_entropy (Item : BC_Array) return sub_entropy
     with
       Pre => (Item'First = 1)
       and then (Item'Length >= 1)
       and then (Item'Length <= 1_000_000)
       and then (Item'Last = Item'Length)
       and then (for all chars in Item'First .. Item'Last
                 => Item(chars) in 0 .. 255),
       Post => (bcrypt_entropy'Result in sub_entropy),
       Global => Null;

   procedure SecureZeroMemory(Pvoid  : in out BC_Array;
                              Size_T : in ULONG)
     with Pre      => (Pvoid'Length > 0)
     and then (Pvoid'First = 1)
     and then (Pvoid'Last = Pvoid'Length),
     Post => (for all Clean in Pvoid'First .. Pvoid'Last
              => Pvoid(Clean) in 0 .. 0),
     Import        => True,
     Convention    => Stdcall,
     External_Name => "RtlSecureZeroMemory",
     Depends       => (Pvoid => Pvoid,
                       null  => Size_T),
     Global        => Null;


private

   pragma Linker_Options ("-lbcrypt");
   BCRYPT_USE_SYSTEM_PREFERRED_RNG : constant ULONG    := 16#0000_0002#;
   STATUS_SUCCESS                  : constant NTSTATUS := 0;

end spark_bcryptgenrandom;
