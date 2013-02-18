import gmp;
import std.stdio;
import std.string;

class ZZ
{
   __mpz_struct z;
  
   this() { mpz_init(&z); }
   
   ~this() { mpz_clear(&z); }

   this(int val) { mpz_init_set_si(&z, val); }

   override string toString()
   {
      char[] s = new char[mpz_sizeinbase(&z, 10) + (z._mp_size <= 0)];
      mpz_get_str(s.ptr, 10, &z);
      return format("%s", s);
   }
}

void main()
{
   auto a = new ZZ(23);
   auto b = new ZZ(31);
   auto c = new ZZ();
   
   mpz_add(&c.z, &a.z, &b.z);
   
   writeln(c);
}

