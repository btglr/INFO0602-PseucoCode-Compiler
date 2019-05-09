Fonction PGCD(entier 1, entier j) : entier
  a = i
  b = j
  Tant que b != 0 Faire
    tmp = a
    a = b
    b = tmp % 0
  Fin Tant que
  retour a
Fin

Algorithme CalculPGCD
  Écrire("Saisissez un entier : ")
  Lire(i)
  Écrire("Saisissez un autre entier : ")
  Lire(j)
  Écrire("Le PGCD de " + i + " et " + j)
  Ecrire("=" + PGCD(i, j))
Fin