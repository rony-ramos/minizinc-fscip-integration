int: n;
set of int: N = 1..n;

array[N] of var -10.0..10.0: x;
array[N] of var 0..1: z;

% Quadratic constraint (Sum of squares)
constraint sum(i in N)(x[i] * x[i]) <= 150.0;

% Mixed Integer coupling (Big-M style)
constraint forall(i in N)(x[i] <= 10.0 * z[i]);
constraint forall(i in N)(x[i] >= -10.0 * z[i]);

% Cardinality
constraint sum(z) <= n div 2;

% Dense Quadratic Objective interactions
% Maximize shifted products
var float: obj = sum(i in 1..n-1)(x[i] * x[i+1]) + sum(i in 1..n)(x[i] * z[n-i+1]);

solve maximize obj;

output ["obj = \(obj);\n"];
