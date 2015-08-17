selectN(z,Xs,[]) :- !.
selectN(s(N),L,[X|S]) :- el(X,L,R),selectN(N,R,S).

el(X,[X|L],L).
el(X,[Y|L],R) :- el(X,L,R).

subtract(G,[],G).
subtract(G,[X|Xs],Zs) :- remove(G,X,G1),subtract(G1,Xs,Zs).

remove([],X,[]).
remove([X|Gs],X,Gs) :- !.
remove([Y|Gs],X,[Y|Zs]) :- remove(Gs,X,Zs).

group([],[],[]).
group(G,[N1|Ns],[G1|Gs]) :- selectN(N1,G,G1),subtract(G,G1,R),group(R,Ns,Gs).

?- group([aldo,beat,carla,david,evi,flip,gary,hugo,ida],[s(s(z)),s(s(z)),s(s(s(s(s(z)))))],Gs).
