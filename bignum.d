module bignum;
private import gmp;
private import std.string;
private import std.stdio;

class ZZ
{
   __mpz_struct z;
   
   this() { mpz_init(&z); }

   ~this() { mpz_clear(&z); }
   
   this(ulong val) { mpz_init_set_ui(&z, val); }

   this(long val) { mpz_init_set_si(&z, val); }

   this(uint val) { mpz_init_set_ui(&z, val); }

   this(int val) { mpz_init_set_si(&z, val); }

   ZZ binop(alias f)(ZZ b)
   {
      ZZ r = new ZZ();
      f(&r.z, &z, &b.z);
      return r;
   }

   ZZ binop_ul(alias f)(ulong b)
   {
      ZZ r = new ZZ();
      f(&r.z, &z, b);
      return r;
   }

   ZZ binop_l(alias f)(long b)
   {
      ZZ r = new ZZ();
      mpz_set_si(&r.z, b);
      f(&r.z, &z, &r.z);
      return r;
   }

   ZZ binop_i(alias f)(int b)
   {
      ZZ r = new ZZ();
      mpz_set_si(&r.z, b);
      f(&r.z, &z, &r.z);
      return r;
   }

   alias binop!(mpz_add) opAdd;
   alias binop!(mpz_sub) opSub;
   alias binop!(mpz_mul) opMul;

   alias binop_ul!(mpz_add_ui) opAdd;
   alias binop_ul!(mpz_sub_ui) opSub;
   alias binop_ul!(mpz_mul_ui) opMul;

   alias binop_l!(mpz_add) opAdd;
   alias binop_l!(mpz_sub) opSub;
   alias binop_l!(mpz_mul) opMul;

   alias binop_i!(mpz_add) opAdd;
   alias binop_i!(mpz_sub) opSub;
   alias binop_i!(mpz_mul) opMul;

   bool opEquals(ulong c) { return mpz_cmp_ui(&z, c) == 0; }

   bool opEquals(long c) { return mpz_cmp_si(&z, c) == 0; }

   bool opEquals(int c) { return mpz_cmp_si(&z, c) == 0; }

   static ZZ opCall(ulong c) { return new ZZ(c); }

   static ZZ opCall(long c) { return new ZZ(c); }

   static ZZ opCall(int c) { return new ZZ(c); }

   override string toString()
   {
      char[] s = new char[mpz_sizeinbase(&z, 10) + (z._mp_size <= 0)];
      mpz_get_str(s.ptr, 10, &z);
      return format("%s", s);
   }
}

ZZ mpz_call(alias f)(ZZ a, ZZ b)
{
   ZZ r = new ZZ();
   f(&r.z, &a.z, &b.z);
   return r;
}

alias mpz_call!(mpz_gcd) gcd;

