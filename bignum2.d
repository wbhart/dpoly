module bignum;
private import gmp;
private import std.string;
private import std.stdio;

struct _bin_exp(S, T, Op)
{
   S val1;
   T val2;

   auto _get() 
   {
      auto temp = new ZZ();
      static if (!is(T == int))
         Op.eval(temp, val1._get(), val2._get());
      else
         Op.eval(temp, val1._get(), val2);
      return temp;
   }

   this(S v1, T v2) { val1 = v1; val2 = v2; }
}

template opOp(string T, string Op)
{
   const char[] opOp = 
   "auto t = _bin_exp!(" ~ T ~ ", S, " ~ Op ~ ")(this, a);
   return _exp!(_bin_exp!(" ~ T ~ ", S, " ~ Op ~ "))(t);";
}

struct _exp(T)
{
   T expr;

   this(T val) { expr = val; }

   auto _get() { return expr._get(); }

   auto opBinary(string op, S)(S a)
   {
      static if (op == "*") { mixin(opOp!("_exp!(T)", "_mul_op")); }
      else static if (op == "+") { mixin(opOp!("_exp!(T)", "_add_op")); }
      else static if (op == "-") { mixin(opOp!("_exp!(T)", "_sub_op")); }
   }
}

static void evalfn_ui(alias f, S)(ZZ a, ZZ b, S c)
{
   f(&a.z, &b.z, c);
}

static void evalfn_si(alias f, alias g, S)(ZZ a, ZZ b, S c)
{
   if (c >= 0) f(&a.z, &b.z, c);
   else g(&a.z, &b.z, -c);
}

static void evalfn(alias f)(ZZ a, ZZ b, ZZ c)
{
   f(&a.z, &b.z, &c.z);
}

struct _mul_op
{
   alias evalfn_ui!(mpz_mul_si, int) eval;
   alias evalfn_ui!(mpz_mul_si, long) eval;
   alias evalfn_ui!(mpz_mul_ui, ulong) eval;
   alias evalfn!(mpz_mul) eval;
}

struct _add_op
{
   alias evalfn_si!(mpz_add_ui, mpz_sub_ui, int) eval;
   alias evalfn_si!(mpz_add_ui, mpz_sub_ui, long) eval;
   alias evalfn_ui!(mpz_add_ui, ulong) eval;
   alias evalfn!(mpz_add) eval;
}

struct _sub_op
{
   alias evalfn_si!(mpz_sub_ui, mpz_add_ui, int) eval;
   alias evalfn_si!(mpz_sub_ui, mpz_add_ui, long) eval;
   alias evalfn_ui!(mpz_sub_ui, ulong) eval;
   alias evalfn!(mpz_sub) eval;
}

class ZZ
{
   __mpz_struct z;
   
   this() { mpz_init(&z); }
   
   ~this() { mpz_clear(&z); }

   this(ulong val) { mpz_init_set_ui(&z, val); }
   this(long val) { mpz_init_set_si(&z, val); }
   this(int val) { mpz_init_set_si(&z, val); }

   static ZZ opCall(ulong c) { return new ZZ(c); }
   static ZZ opCall(long c) { return new ZZ(c); }
   static ZZ opCall(int c) { return new ZZ(c); }

   auto _get() { return this; }

   auto opBinary(string op, S)(S a)
   {
      static if (op == "*") { mixin(opOp!("ZZ", "_mul_op")); }
      else static if (op == "+") { mixin(opOp!("ZZ", "_add_op")); }
      else static if (op == "-") { mixin(opOp!("ZZ", "_sub_op")); }
   }

   auto opAssign(ZZ, T, Op)(_exp!(_bin_exp!(ZZ, T, Op)) ex)
   {
      static if(is(typeof(ex) == int))
      {
         mpz_set_si(&v, ex);
      } else static if (is(typeof(ex) == long))
      {
         mpz_set_si(&v, ex);
      } else static if (is(typeof(ex) == ulong))
      {
         mpz_set_ui(&v, ex);
      } else static if (is(typeof(ex) == ZZ))
      {
         mpz_set(&v, &ex.v);
      } else
      {
         static if (!is(T == int))
            Op.eval(this, ex.expr.val1._get(), ex.expr.val2._get());
         else
            Op.eval(this, ex.expr.val1._get(), ex.expr.val2);
      }

      return this;
   }

   bool opEquals(ulong c) { return mpz_cmp_ui(&z, c) == 0; }
   bool opEquals(long c) { return mpz_cmp_si(&z, c) == 0; }
   bool opEquals(int c) { return mpz_cmp_si(&z, c) == 0; }

   override string toString()
   {
      char[] s = new char[mpz_sizeinbase(&z, 10) + (z._mp_size <= 0)];
      mpz_get_str(s.ptr, 10, &z);
      return format("%s", s);
   }
}
