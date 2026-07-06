with Interfaces.C;
with Interfaces.C.Strings;
with System;

package DataType_Win32 is

   subtype BYTE       is Interfaces.C.unsigned_char;
   subtype UCHAR      is Interfaces.C.unsigned_char;
   subtype WORD       is Interfaces.C.unsigned_short;
   subtype DWORD      is Interfaces.C.unsigned_long;
   subtype ULONG      is Interfaces.C.unsigned_long;
   subtype LONG       is Interfaces.C.long;
   subtype ULONGLONG  is Interfaces.C.unsigned_long_long;
   subtype SIZE_T     is Interfaces.C.size_t;

   subtype HANDLE     is System.Address;
   subtype NTSTATUS   is Interfaces.C.long;

   subtype BOOL       is Interfaces.C.int;
   TRUE_VALUE         : constant BOOL := 1;
   FALSE_VALUE        : constant BOOL := 0;

   subtype PVOID      is System.Address;
   subtype LPVOID     is System.Address;
   subtype LPCVOID    is System.Address;

   subtype LPSTR      is Interfaces.C.Strings.chars_ptr;
   subtype LPCSTR     is Interfaces.C.Strings.chars_ptr;

   type WCHAR is new Interfaces.C.unsigned_short;
   type LPWSTR is access all WCHAR
     with Convention => C;

end DataType_Win32;
