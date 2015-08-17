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

trans([X],[s(z),X]).
trans([X|Xs],[N,X]) :- length([X|Xs],N).

length([],z).
length([Y|Ys],s(N)) :- length(Ys,N).

encode(Xs,X) :- pack(Xs,Ys),encode_helper(Ys,X).
encode_helper([],[]).
encode_helper([X|Xs],[Z|Zs]) :- trans(X,Z),encode_helper(Xs,Zs).

?- encode([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
