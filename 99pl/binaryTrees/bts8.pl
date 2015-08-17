count_leaves(nil,z).
count_leaves(t(X,nil,nil),s(z)) :- !.
count_leaves(t(X,L,R),N) :- 
    count_leaves(L,NL), count_leaves(R,NR), add(NL,NR,N).

add(z,N,N).
add(s(N1),N2,s(N)) :- add(N1,N2,N).
 
?- count_leaves(t(x, t(x, t(x, nil, nil), t(x, nil, nil)), t(x, nil, t(x, nil, nil))),N).
