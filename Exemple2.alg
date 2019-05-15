Fonction PGCD(entier i, entier j) : entier
  a = i
  b = j
  Tant que b != 0 Faire
    tmp = a
    a = b
    b = tmp % b
  Fin Tant que
  retour a
Fin

Algorithme CalculPGCD
  Ecrire("Saisissez un entier : ")
  Lire(i)
  Ecrire("Saisissez un autre entier : ")
  Lire(j)
  Ecrire("Le PGCD de " + i + " et " + j)
  Ecrire(" = " + PGCD(i, j) + "\n")
Fin