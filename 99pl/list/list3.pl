element_at(X,[X|XS],z).
element_at(X,[Z,Y|Ys],s(N)) :- element_at(X,[Y|Ys],N).

?- element_at(X,[a,b,c,d,e],s(s(z))).
