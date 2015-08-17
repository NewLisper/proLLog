insert_at(E,[],N,[]).
insert_at(E,[X|Xs],s(z),[E,X|Xs]).
insert_at(E,[X|Xs],s(N),[X|Zs]) :- insert_at(E,Xs,N,Zs).

?- insert_at(alfa,[a,b,c,d],s(s(z)),L).
