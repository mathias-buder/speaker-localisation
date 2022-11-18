%{
a = 123;
b = fix(mod(a/100,100))

c = fix(mod(a,100)/10)
d = fix(mod(a,10))
%}

clc
e = 2.41;
f = fix(e)
g = fix(mod(e*10,10))
h = fix(mod(e*10,1)*10)
