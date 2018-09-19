---
layout: post
title:  "Git Bisect"
author: Fabrice Fontenoy
categories: [ Git ]
image: assets/images/git-bisect.png
comments: false
---

A quoi sert `git bisect` ?
-----------------------

Supposons qu'une régression ait été introduite dans votre code mais vous ne savez pas quand exactement. 
Les seules informations que vous avez, ce sont la référence d'un commit où le problème n'est pas présent et celle d'un autre commit présentant la régression.
`git bisect` permet de parcourir de façon dichotomique les commits existants entre ces deux références jusqu'à trouver celui qui a introduit la régression.

Comment utilise-t-on `git bisect` ?
-----------------------------------

Pour la suite de l'article, nous supposons que les commits suivant ont été effectués :

[//]: #  "![git bisect log](../../../../assets/images/git-bisect-log.png "git bisect log"){: .center-image}"

	8d8885d (HEAD -> master, origin/master) Modify the third file
	3a152d8 Modify the second file
	d101b26 Add a third file
	025fc2c Add a second file
	c8324c9 Modify file1.txt
	46db71c add file1.txt

et que nous souhaitons savoir quel commit a introduit le fichier `file3.txt`.
Vous me direz qu'il y a beaucoup plus simple pour avoir la réponse mais cette exemple permet de facilement comprendre comment utiliser `git bisect`.


`git bisect` se démarre simplement de la façon suivante :

	$ git bisect start
	$ git bisect good 46db71c 
	$ git bisect bad 8d8885d

_git_ va alors automatiquement se placer sur le commit situé entre le "bon" et le "mauvais" commit (`025fc2c` dans notre cas).
Une fois sur ce commit vous serez alors capable de dire si le problème est présent ou non sur ce commit.

Si ce commit présente la régression, il faudra alors le préciser à _git_ avec la commande suivante :

	$ git bisect bad

Sinon, il faudra taper la commande suivante :

	$ git bisect good

Dans notre cas précis, le fichier `file3.txt` n'est pas présent sur le commit `025fc2c`.
Il faut donc taper la seconde commande `git bisect good`.

Ensuite _git_ va à nouveau changer votre espace de travail pour se placer sur le commit situé entre le dernier "bon" commit renseigné et le dernier "mauvais" commit renseigné.
L'opération se réitère jusqu'à ce que _git_ soit capable de déterminer quel est le commit qui a introduit la régression et il affichera un message comme le suivant :

	d101b2632de44f59d20be097f0ded50fb8bf1e01 is the first bad commit
	commit d101b2632de44f59d20be097f0ded50fb8bf1e01
	Author: Fabrice Fontenoy <xxxxxxxxxxxxxxxxxxx@xxxxxxxxx.com>
	Date:   Tue Sep 18 22:38:31 2018 +0200

	Add a third file

	:000000 100644 0000000000000000000000000000000000000000 dc2f4460d8f0ef118cb169442639f5dda8e14e82 A      file3.txt.


Une fois ce commmit déterminé, _git_ vous laissera sur ce commit vous permettant ainsi d'investiguer le problème.
Si vous demander le status à _git_, il vous répondra que vous êtes sur une branche détachée et qu'un _bisect_ est en cours:

	$ git status

	HEAD detached at d101b26
	You are currently bisecting, started from branch 'master'.
	(use "git bisect reset" to get back to the original branch)

	nothing to commit, working directory clean


Si vous voulez revenir sur votre dernier commit, il vous suffit de taper :

	$ git bisect reset


Vous trouvez ça long et fastidieux ?
------------------------------------

Il y a des cas de figure où vous savez exactement quoi vérifier pour dire si le commit est bon ou pas.
C'est exactement notre cas avec la présence ou non du fichier `file3.txt`.
Et ben, _git_ a prévu ça et vous permet d'automatiser votre recherche dichotomique avec `git bisect`.

Pour cela, il suffit d'écrire un script qui doit sortir avec la valeur '0' si le commit est bon et un entier entre '1' et '127' (inclus), '125' exclu, si le commit n'est pas bon.

Dans notre cas, on peut écrire le script suivant :

	$ more check.sh

	#!/bin/sh

	if [ -f file3.txt ]; then
		echo "file3.txt exists"
		exit 1
	else
		echo "file3.txt does not exist"
		exit 0
	fi

Ensuite une fois la commande `git bisect` initialisée comme vu précédemment :

	$ git bisect start
	$ git bisect good 46db71c 
	$ git bisect bad 8d8885d

Il suffit de lancer la commande suivante :

	$ git bisect run check.sh

A partir de là, _git_ continue tout seul jusqu'à trouver le commit qui a introduit le problème et vous l'affiche :

	running check.sh
	file3.txt does not exist
	Bisecting: 0 revisions left to test after this (roughly 1 step)
	[3a152d8cd92278cd2ab1170fef069b63c29f79d3] Modify the second file
	running check.sh
	file3.txt exists
	Bisecting: 0 revisions left to test after this (roughly 0 steps)
	[d101b2632de44f59d20be097f0ded50fb8bf1e01] Add a third file
	running check.sh
	file3.txt exists
	d101b2632de44f59d20be097f0ded50fb8bf1e01 is the first bad commit
	commit d101b2632de44f59d20be097f0ded50fb8bf1e01
	Author: Fabrice Fontenoy <xxxxxxxxxxxxxxx@xxxxxxxxx.com>
	Date:   Tue Sep 18 22:38:31 2018 +0200

	Add a third file

	:000000 100644 0000000000000000000000000000000000000000 dc2f4460d8f0ef118cb169442639f5dda8e14e82 A      file3.txt
	bisect run success


Conclusion
----------

J'en ai fini avec les fonctionnalités principales de la commande `git bisect`.
D'autres options sont néanmoins dispobibles telles que `git bisect log` pour voir ce qui a été fait jusqu'à maintenant (quels commits ont été marqués comme bons et mauvais) ou encore `git bisect visualize` pour connaître quels sont les prochains commits suspects qui vont être passés en revue.
Pour plus d'information, je vous laisse regarder le _man_ de `git bisect`.

