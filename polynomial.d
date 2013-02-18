module polynomial;
private import std.algorithm;
private import std.conv;
private import std.stdio;
private import bignum;

class poly(T, string X)
{
   T[] coeff;

   this()() {}
   this(S)(S c) 
   { 
      static if (is(S == monomial!(T, X)))
      {
         coeff.length = c.exp + 1;
         for (size_t i = 0; i < c.exp; i++)
            coeff[i] = to!(T)(0);
         coeff[c.exp] = to!(T)(1);
      } else static if (is(S == void[])) {}
      else static if (is(typeof(c[0]))) 
         coeff = to!(T[])(c);
      else { if (c != 0) coeff = [T(c)]; }
   }

   void normalise()
   {
      while (coeff.length && coeff[$ - 1] == 0)
         coeff.length = coeff.length - 1;
   }

   static poly!(T, X) opCall(S)(S p)
   {
      static if (__traits(hasMember, S, "coeff"))
      {
         static if(is(typeof(p.coeff) == T[]))
            return p;
         else
         {
            auto c = T(p);
            return new poly!(T, X)([c]);
         }
      } else 
      {
         static if(is(typeof(S.exp)))
            return new poly!(T, X)(p);
         else
            return new poly!(T, X)([p]);
      }
   }

   static monomial!(T, X) gen()
   {
      return new monomial!(T, X)(1);
   }

   poly!(T, X) opAdd(S)(S b)
   {
      static if (is(S == poly!(T, X)))
      {
         size_t i;
         auto r = new poly!(T, X)();

         r.coeff.length = max(coeff.length, b.coeff.length);
      
         for (i = 0; i < min(coeff.length, b.coeff.length); i++)
            r.coeff[i] = coeff[i] + b.coeff[i];

         for ( ; i < coeff.length; i++)
            r.coeff[i] = coeff[i];

         for ( ; i < b.coeff.length; i++)
            r.coeff[i] = b.coeff[i];

         r.normalise();
 
         return r;
      } else
      {
         auto t = poly!(T, X)(b);
         return this + t;
      }
   }

   bool opEquals(int p)
   {
      if (p == 0) return coeff.length == 0;
      else return coeff.length == 1 && coeff[0] == p;
   }

   string br(size_t i, string s)
   {
      static if (is(typeof(coeff[i].coeff)))
         if (coeff[i].coeff.length > 1)
            return s;
 
      return "";
   }

   override string toString()
   {
      string s = "";
      size_t i;

      if (coeff.length)
         for (i = coeff.length - 1; i > 1; i--)
            s = s ~ br(i, "(") ~ coeff[i].toString() ~ br(i, ")") 
                 ~ "*" ~ X.stringof[1..$-1] ~ "^" ~ to!(string)(i) ~ " + ";

      if (coeff.length > 1)
         s = s ~ br(1, "(") ~ coeff[1].toString() ~ br(1, ")") 
               ~ "*" ~ X.stringof[1..$-1] ~ " + ";

      if (coeff.length)
         s = s ~ br(0, "(") ~ coeff[0].toString() ~ br(0, ")");
      else
         s = "0";
      
      return s;
   }
}

class monomial(T, string X)
{
   size_t exp;

   this(size_t p) { exp = p; }

   monomial!(T, X) opPow(size_t p)
   {
      return new monomial!(T, X)(p*exp);
   }

   poly!(T, X) opMul(S)(S c)
   {
      auto t = new poly!(T, X)(this);
      t.coeff[exp] = T(c);
      return t;
   }

   override string toString()
   {
      if (exp > 1)
         return X.stringof[1..$-1] ~ "^" ~ to!(string)(exp);
      else if (exp)
         return X.stringof[1..$-1];
      else
         return "1";
   }
}

