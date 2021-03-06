import std.stdio;
import bignum;
import gmp;
import polynomial;

void main()
{
   alias poly!(ZZ, "x") R;
   alias poly!(R, "y") S;

   auto x = R.gen();
   auto y = S.gen();

   auto A = 4*x^^2 + 3*x + 2;
   auto B = 5*x^^2 + 6*x + 7;
   auto C = 8*x^^2 + 9*x + 10;

   auto D = A*y^^2 + B*y + C;
   auto E = S(D);

   for (long i = 0; i < 10000000; i++)
      E += D;

   writeln(E);
   writeln(D);
}	
