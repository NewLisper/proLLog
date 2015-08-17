slice([],S,E,[]).
slice([X|Xs],s(S),s(E),Ys) :- slice(Xs,S,E,Ys).
slice([X|Xs],s(z),s(E),[X|Ys]) :- slice(Xs,s(z),E,Ys).
slice([X|Xs],s(z),s(z),[X]).

?- slice([a,b,c,d,e,f,g,h,i,k],s(s(s(z))),s(s(s(s(s(s(s(z))))))),L).
