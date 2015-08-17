complete_binary_tree(N,T) :- complete_binary_tree(N,T,s(z)).

complete_binary_tree(N,nil,A) :- great(A,N), !.
complete_binary_tree(N,t(x,L,R),A) :- less(A,N),
    muti2(A,AL), add1(AL,AR),
    complete_binary_tree(N,L,AL),
    complete_binary_tree(N,R,AR).

great(s(X),z).
great(s(N1),s(N2)) :- great(N1,N2).

less(z,X).
less(s(N1),s(N2)) :- less(N1,N2).

muti2(z,z).
muti2(s(N1),s(s(N2))) :- muti2(N1,N2).

add1(N,s(N)).

?- complete_binary_tree(s(s(s(s(z)))),T).
