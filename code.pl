queen(N,Qs) :- place(N,Qs,z).

place(N,[],N):- !.
place(N,[Q|Qs],Col) :- place(N,Qs,s(Col)),select(N,Qs,Q),valid(Q,Qs).

select(s(N),Qs,s(N)) :- notin(s(N),Qs).
select(s(N),Qs,DN) :- select(N,Qs,DN).

in(N,[N|Ns]) :-!.
in(N,[N1|Ns]) :- in(N,Ns).

notin(N,Ns) :- in(N,Ns),!,fail.
notin(N,Ns).

valid(Q,Qs) :- invalid(Q,Qs,s(z)),!,fail.
valid(Q,Qs).

invalid(NQ,[Q|Qs],D) :- diagonal(NQ,Q,D),!.
invalid(NQ,[Q|Qs],D) :- invalid(NQ,Qs,s(D)).

diagonal(NQ,Q,Dif) :- subtract(Q,NQ,Dif).
diagonal(NQ,Q,Dif) :- subtract(NQ,Q,Dif).

subtract(N,z,N).
subtract(s(N1),s(N2),N) :- subtract(N1,N2,N).

?-queen(s(s(s(s(s(s(s(s(z)))))))),Qs).

