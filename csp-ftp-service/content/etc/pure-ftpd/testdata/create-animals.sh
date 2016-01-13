#!/bin/bash
rm *.zip *.jpg
for animal in kitten puppy lemur puppies
do
    rm -rf $animal
    mkdir $animal
    find -x ~ -not -path '*SecondLife*' -iname '*'$animal'*jpg' -print 2>/dev/null -exec cp "{}" ./$animal ";" 
    zip -0 ${animal}.zip $animal/*
    rm -rf *jpg
done
