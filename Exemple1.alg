Procédure pair(entier i)
  Ecrire(i + " est pair")
  retour
Fin

Procédure impair(entier i)
  Ecrire(i + " est impair")
  retour
Fin

Algorithme Exemple
  Pour i allant de 1 à 10 faire
    Ecrire("Tapez votre entier : ")
    Lire(j)
    Si j%2 == 0 alors
      pair(j)
      Ecrire("\n")
    Sinon
      impair(j)
      Ecrire("\n")
    Fin Si
  Fin Pour
Fin