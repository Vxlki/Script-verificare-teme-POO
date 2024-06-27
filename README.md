# Script-verificare-teme-POO

# Ziua 1: Documentatia

# Ziua 2: Documentatie + creeare ierarhie de clase

# Ziua 3: Implementare pe headere, cu optiunea -h

# Ziua 4: Imbunatatirea -h, afisarea unui tree reprezentand mostenirile

# Ziua 5: Implementare optiune -c

# Ziua 6:  Implementare optiune -t, care afiseaza un tree, cu toate clasele (trebuie dat header-ul de la care se mostenesc celelalte clase)

# Ziua 7: Implementare optiune -hc/-ch care asteapta ca parametru o sursa si un header in ordinea asta

# Ziua 8: Implementare optiune -o pentru detectarea dependentelor circulare

# Model de testare a tuturor functionalitatilor. Se va rula script-ul astfel:
#   1.  ./script.sh -h AMaritim.h
#   2.  ./script.sh -h CAutobuz.h
#   3.  ./script.sh -h CAutobuzmini.h
#   4.  ./script.sh -h ITransport.h
#   5.  ./script.sh -h AAerian.h
#   6.  ./script.sh -h CMasina.h
#   7.  ./script.sh -c CMasina.cpp
#   8.  ./script.sh -t .
#   9.  ./script.sh -ch CMasina.cpp CMasina.h
#   10. ./script.sh -o .

# Bug-uri cunoscute: 
#   1. Daca constructorii sunt comentati, sunt in continuare vazuti ca existand;
#   2. Acelasi lucru se intampla si cu functionalitatea de a verifica daca functiile sunt declarate in header sau implementate in sursa;