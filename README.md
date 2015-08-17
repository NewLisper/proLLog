# proLLog
A simple implementation of Prolog, the compiler is written in Haskell, the abstract machine is written in c.

# About the Compiler
Due to lack of documentation , I have to write the compiler by my own creation.  Without using state monad (I don't know how to use it well),I pass and return the state (lookup map etc.. ) explicitly during the compilation , so some
codes look like shit. However, the codes are just 300 lines (with the help of parsec) and fairly easy to read.

# About the Abstract Machine
The abstract machine is almost based on [WAMBOOK](http://wambook.sourceforge.net) , but I change some mistakes in the book and add several instructions for convenience. In the optimization part, I just implement list and constant. I
wish I have time to finish it in some day.

#About 99 Prolog Problems
[It](https://sites.google.com/site/prologsite/home) provides some interesting problems for beginners. I use some of them for testing,but it's difficult to finish them all without built-ins' support. My implementation also lacks Num and related Ops, so Ints are represented in church code (z,s(z),s(s(z))..),it does cause efficiency issues.

#How to use it
The run.sh script is just a example for running code.pl.
You need to use ./compiler XXX to generate XXX.wam, then use ./wam XXX.wam to run instructions.
