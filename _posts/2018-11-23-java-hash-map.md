---
layout: post
title:  Pourquoi bien implémenter les méthodes <i>equals()</i> et <i>hashCode()</i> ?
author: Fabrice Fontenoy
categories: [ Java ]
image: assets/images/java-hashmap/java-hashmap.jpg
description: Cet article explique comment fonctionne une hashmap et pourquoi il est impératif de bien implémenter les méthodes equals() et hashCode()
comments: false
---

## Rien ne va plus dans la `HashMap` ?

Considérons le bout de code suivant :

```java
package com.truelines.blog.java.hashmap;

import java.util.HashMap;
import java.util.Map;

import com.truelines.blog.java.hashmap.data.Car;
import com.truelines.blog.java.hashmap.data.Person;

/**
 * Error case to point out what to take care of when using an hashmap
 */
public class ErrorCase {

	/**
	 * The hashmap of cars
	 */
	private static Map<Person, Car> carOwnership = new HashMap<>();

	/**
	 * Get the car belonging to the person whose first name and family name are
	 * given in parameter
	 *
	 * @param pFirstName  the person's first name
	 * @param pFamilyName the person's family name
	 * @return the car belonging to the given person
	 */
	public static Car getCar(String pFirstName, String pFamilyName) {
		return carOwnership.get(new Person(pFirstName, pFamilyName));
	}

	/**
	 * main method
	 *
	 * @param args not used
	 */
	public static void main(String[] args) {

		// Insert my car into the map
		Person me = new Person("Fabrice", "Fontenoy");
		Car myCar = new Car("FF-123-ZZ");
		carOwnership.put(me, myCar);

		// Check that my car is in the map
		System.out.println("Is my car in the map? " 
			+ (getCar("Fabrice", "Fontenoy") != null));
	}
}

```

Avec les classes `Person` et `Car` suivantes:

```java
package com.truelines.blog.java.hashmap.data;

/**
 * This class represents a person
 */
public class Person {

	/**
	 * The person's first name
	 */
	private final String firstName;

	/**
	 * The person's family name
	 */
	private final String familyName;

	/**
	 * Constructor
	 *
	 * @param pFirstName  the person's first name
	 * @param pFamilyName the person's family name
	 */
	public Person(String pFirstName, String pFamilyName) {
		firstName = pFirstName;
		familyName = pFamilyName;
	}
}

```

```java
package com.truelines.blog.java.hashmap.data;

/**
 * This class represents a car
 */
public class Car {

	/**
	 * The car license plate
	 */
	private final String licensePlate;

	/**
	 * Constructor
	 *
	 * @param pLicensePlate the car license plate
	 */
	public Car(String pLicensePlate) {
		licensePlate = pLicensePlate;
	}

}

```
Si vous exécutez ce code, vous allez avoir le résultat suivant :

	Is my car in the map? false

Pourquoi la méthode `getCar()` retourne `false` alors que la voiture de Fabrice Fontenoy a bien été inséré dedans ?
Pour comprendre pouquoi, je vous propose d'abord de voir comment fonctionne une `HashMap`. 

## Comment fonctionne une HashMap ?

Une `HashMap` peut-être vu comme un tableau de seaux ( tableau de "buckets") :

![HashMap Representation](../../../../assets/images/java-hashmap/HashMap.jpg "HashMap Representation"){: .center-image}

Chaque seau est identifié par un code, le hashcode. 
Lorsque vous ajoutez un élément dans une hashmap, c'est-à-dire un couple `(K,V)` où `K` est la clef et `V` la valeur, le hashcode de `K` va être calculé et c'est ce hashcode qui va déterminer dans quel seau sera placé le couple `(K,V)`.
C'est donc là qu'intervient la méthode `hashCode()`. Cette méthode est appelée sur `K` pour déterminer le seau dans lequel placer le couple `(K,V)`.

Et maintenant, qu'est-ce qui se passe quand on souhaite récupérer un élément d'une HashMap avec la méthode `get(K)` ?
Pour récupérer un élément de la HashMap, il faut d'abord savoir dans quel seau cet élément est stocké. Et donc pour cela, la méthode `hashCode()` est de nouveau appelé sur l'élément `K`.
Une fois le seau récupéré, il faut rechercher le couple `(K, V)` dans ce seau. 

D'ailleurs, comment est représenté ce seau ? J'y reviendrai un peu tard mais pour le moment considérons que le seau est une liste de couple `(K,V)`.
Lorsqu'un `get(K)` est appelé, une fois le seau récupéré, la méthode `equals()` est appelé sur l'élément `K`des couples `(K,V)` un à un jusqu'à trouver le couple de la liste dont l'élément `K` est égale à l'élément `K` passé en paramètre de la méthode `get()`.

![HashMap get method call](../../../../assets/images/java-hashmap/HashMap2.jpg "HashMap get method call"){: .center-image}


## En quoi l'exemple ci-dessus pose problème ?

Le problème avec l'exemple ci-dessus c'est que la classe `Person` ne redéfinit pas la méthode `hashCode()`.
Par défaut, la méthode `hashCode()` de la classe `Object` retourne un entier converti à partir de l'addresse mémoire de l'instance de l'objet.
Dans notre exemple ci-dessus, une seconde instance de `Person` est créé pour rechercher la voiture. Ainsi, sans redéfinir la méthode `hashCode()`, deux instances d'une classe retourneront toujours deux hash codes différents puisque les deux instances auront des adresses différentes. Et donc lors de l'appel à la méthode `get(K)`, aucun seau ne sera trouvé et `null` sera retourné.

Redéfinissons alors la méthode `hashCode()` ! Mais comment en fait ? Que doit-on respecter ?

Si vous avez bien suivi, il faut donc que deux objets égaux (au sens métier) retournent le même hash code afin que le même seau soit retourné.

Même si ça ne correspond pas à la réalité, nous allons considérer que deux personnes sont "égales" si elles ont le même prénom et le même nom de famille.
Nous allons définir la méthode `hashCode()` de façon très triviale dans un premier temps en retournant la somme du nombre de caractères du prénom et du nom de famille.
Ainsi, en donnant le même prénom et nom, peu importe la casse utilisée, nous aurons le même hashcode et donc le même seau.

```java
@Override
public int hashCode() {
	return firstName.length() + familyName.length();
]
```

Maintenant, relançons notre test et voyons le résultat : 

	Is my car in the map? false

Pourquoi le résultat est-il encore faux ?

Tout simplement parce que la méthode `equals()` n'a pas été redéfinie. Le bon seau a bien été récupéré mais aucune personne correspondante n'a été trouvée.
En effet, la méthode `equals()` n'ayant pas été redéfinie, la méthode `equals()` par défaut définie par la classe `Object` est exécutée et cette méthode retourne `true` si et seulement si les références des instances testées sont égales. Comme dans notre exemple, nous avons deux instances différentes, leur référence ne sont donc pas égales et donc la méthode `get(K)` ne trouve aucun élément correspondant dans le seau.

Redéfinissons alors la méthode `equals()` de façon à ce que notre test fonctionne :

```java
@Override
public boolean equals(Object obj) {
	boolean result = false;
	if (obj instanceof Person) {
		// We consider for simplification purpose that familyName 
		// and firstName are not null
		result = ((Person) obj).familyName.equals(familyName) 
			&& ((Person) obj).firstName.equals(firstName);
	}
	return result;
} 
```

Et relançons notre test :

	Is my car in the map? true

Nous avons enfin un test qui fonctionne mais nous allons voir dans la section suivante que l'implementation proposée n'est pas du tout optimale.


## Commment implémenter les méthodes `hashCode()`et `equals()` ?

Pour l'implémentation des méthodes `equals()` et `hashCode()`, il faut respecter deux règles :
* Deux instances `A` et `B` égales (ie. `A.equals(B) == true`) doivent impérativement retourner le même hash code (ie. `A.hashCode() == B.hashCode()`)
* Limiter autant que possible les collisions de hash code

D'après ce qu'on a vu dans les sections précédentes, la première règle tombe sous le sens.

Concernant la seconde règle, pourquoi faut-il éviter les collisions ?

Cette règle n'est pas un impératif mais ne pas respecter cette règle risque de détériorier les performances de votre HashMap.
En effet, si vous avez des collisions, vous aurez alors plusieurs éléments dans un même seau et donc l'itération sur la liste prendra potentiellement plus de temps si vous avez beaucoup d'éléments dans cette liste. D'autant plus que les seaux ne sont pas exactement des listes.

Un seau est à sa création un ensemble de noeud dont chaque noeud à lien vers le noeud suivant.
Enfin ça, c'est vrai si le nombre de noeuds du seau est inférieur à la constante `TREEIFY_THRESHOLD` définie dans la classe HashMap et égale à `8`.
Au-delà de ce nombre, les noeuds de type `Node` sont convertis en `TreeNode`. Non seulement la conversion en arbre impacte la performance lors de l'ajout du neuvième élément mais ensuite, bien que la recherche dans un arbre est plus rapide, elle reste moins performante que la recherche dans une liste avec très peu d'éléments.
Et inversement, lorsque la taille d'un seau devient inférieur à la constante `UNTREEIFY_THRESHOLD` égale à `6`, les `TreeNode` sont reconvertis en `Node`.

Ainsi, il est d'usage de faire en sorte que deux éléments différents retournent autant que possible des hash codes différents. De cette façon, chaque seau ne contiendra qu'un seul élément ou presque et la récupération d'éléments se fera en temps constant.
Je dédierai un post sur ce sujet mais, en pratique, on utilise un nombre premier, `31` par exemple, pour construire le hash code.

Dans notre exemple, en considérant pour simplifer que `firstName` et `familyName` sont non-nuls, on peut alors implémenter la méthode `hashCode()` de la façon suivante :

```java
	/**
	 * Prime number for hashCode computation
	 */
	private static final int PRIME_NUMBER = 31;

	@Override
	public int hashCode() {
		int result = 1;
		// We consider for simplification purpose that familyName 
		// and firstName are not null
		result = PRIME_NUMBER * result + familyName.hashCode();
		result = PRIME_NUMBER * result + firstName.hashCode();
		return result;
	}
```

Si vous demandez à votre IDE préféré, Eclipse par exemple, de générer la méthode `hashCode()`, il vous générera une méthode similaire à la précédente avec en plus la gestion des champs `null`.

Une autre méthode d'implémentation de la méthode `hashCode()` mais qui revient en fin de compte au même, est de faire appel à la méthode `Objects.hash(Object...)` de Java :

```java
	public int hashCode() {
		return Objects.hash(firstName, familyName);
	}
```
Si vous allez vous le code de la classe `Objects`, vous remarquerez que c'est la même opération qui est effectuée.

## Conclusion

Nous avons vu dans cette article les grandes lignes du fonctionnement d'une `HashMap`, nécessaires à sa bonne utilisation. Sans connaître son fonctionnement ou si vous ne respectez pas les règles principales énoncées précédemment, vous allez forcément rencontrer des problèmes de disparitions mystérieuses d'éléments.
Pour en savoir plus sur les `HashMap`, je vous encourage à aller vous balader dans la classe `HashMap` pour comprendre le fonctionnement en détail.


