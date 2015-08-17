jump(N,p(X1,Y1),p(X2,Y2)) :- add(X1,s(z),X2),add(Y1,s(s(z)),Y2),less(X2,N),less(Y2,N).
jump(N,p(X1,Y1),p(X2,Y2)) :- add(X1,s(s(z)),X2),add(Y1,s(z),Y2),less(X2,N),less(Y2,N).
jump(N,p(X1,Y1),p(X2,Y2)) :- add(X1,s(s(z)),X2),sub(Y1,s(z),Y2),less(X2,N),less(Y2,N).
jump(N,p(X1,Y1),p(X2,Y2)) :- add(X1,s(z),X2),sub(Y1,s(s(z)),Y2),less(X2,N),less(Y2,N).
jump(N,p(X1,Y1),p(X2,Y2)) :- sub(X1,s(z),X2),sub(Y1,s(s(z)),Y2),less(X2,N),less(Y2,N).
jump(N,p(X1,Y1),p(X2,Y2)) :- sub(X1,s(s(z)),X2),sub(Y1,s(z),Y2),less(X2,N),less(Y2,N).
jump(N,p(X1,Y1),p(X2,Y2)) :- sub(X1,s(s(z)),X2),add(Y1,s(z),Y2),less(X2,N),less(Y2,N).
jump(N,p(X1,Y1),p(X2,Y2)) :- sub(X1,s(z),X2),add(Y1,s(s(z)),Y2),less(X2,N),less(Y2,N).

add(z,N,N).
add(s(N1),N2,s(N)) :- add(N1,N2,N).

sub(N,z,N).
sub(s(N1),s(N2),N) :- sub(N1,N2,N).

less(z,s(N)).
less(s(N1),s(N2)) :- less(N1,N2).

muti(z,N,z).
muti(s(M),N,Zs) :- muti(M,N,Ys),add(Ys,N,Zs).

knight(N,p(X,Y),S) :- muti(N,N,M),sub(M,s(z),M1),knight(N,M1,p(X,Y),[p(X,Y)],S).

knight(N,z,p(X,Y),Visited,[p(X,Y)]).
knight(N,s(M),p(X,Y),Visited,[p(X,Y)|Steps]) :-
     jump(N,p(X,Y),p(Nx,Ny)),
     notin(p(Nx,Ny),Visited),
     knight(N,M,p(Nx,Ny),[p(Nx,Ny)|Visited],Steps).

in(p(X,Y),[p(X,Y)|Vs]) :- !.
in(p(X,Y),[V|Vs]) :- in(p(X,Y),Vs).

notin(P,Vs) :- in(P,Vs),!,fail.
notin(P,VS).

?-knight(s(s(s(s(s(z))))),p(z,z),S).
