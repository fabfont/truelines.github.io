---
layout: post
title:  Java HashMap ou pourquoi bien implémenter les méthodes equals() et hashCode()
author: Fabrice Fontenoy
categories: [ Java ]
image: assets/images/java-hashmap/java-hashmap.png
description: Cet article explique comment fonctionne une hashmap et pourquoi il est impératif de bien implémenter les méthodes equals() et hashCode()
comments: false
---

## Qu'est-ce qui ne va pas avec les `HashMap` ?

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
		System.out.println("Is my car in the map? " + (getCar("Fabrice", "Fontenoy") != null));
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
