pack(Xs,X) :- pack(Xs,[],X).
pack([],Acc,[]).
pack([X],Acc,[[X|Acc]]).
pack([X,X|Xs],Acc,Zs) :- pack([X|Xs],[X|Acc],Zs).
pack([X,Y|Xs],Acc,[[X|Acc]|Zs]) :- notsame(X,Y),pack([Y|Xs],[],Zs).
notsame(a,b).
notsame(b,c).
notsame(c,a).
notsame(a,d).
notsame(d,e).


?- pack([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
