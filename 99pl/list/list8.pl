compress([],[]).
compress([X],[X]).
compress([X,X|Xs],Zs) :- compress([X|Xs],Zs).
compress([X,Y|Ys],[X|Zs]) :- notsame(X,Y), compress([Y|Ys],Zs).
notsame(a,b).
notsame(b,c).
notsame(c,a).
notsame(a,d).
notsame(d,e).

?- compress([a,a,a,a,b,c,c,a,a,d,e,e,e,e],X).
