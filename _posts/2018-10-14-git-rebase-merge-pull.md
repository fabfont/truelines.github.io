---
layout: post
title:  "Git Rebase, Merge ou Pull ?"
author: Fabrice Fontenoy
categories: [ Git ]
image: assets/images/git-merge-rebase/git-merge-rebase.png
description: Cet article explique quand doit-on utiliser git merge, git rebase et git pull.
comments: false
---

## A quoi servent `git merge`, `git rebase` et `git pull` ?

On va commencer par le plus simple : qu'est que `git pull` ?
Et bien, c'est très simple, `git pull` c'est l'enchaînement de `git fetch` et de `git merge`.
Oui bon, si vous ne savez pas ce qu'est `git fetch` et `git merge`, ça ne avance pas à grand chose...

<div class="note">
<!--img src="/assets/images/common/tip.png" height="42" width="42"/--><h1>Note</h1>

<p>La commande <i>git pull</i> peut être configurée pour appliquer un <i>git rebase</i> à la place d'un <i>git merge</i> à la suite du <i>git fetch</i>.
Pour que ce soit configuré de façon permanente, taper la commande suivante :</p>

<pre>git config --global pull.rebase true</pre>

<p>Sinon, si vous voulez appliquer un rebase de façon occasionnelle, vous pouvez aussi ajouter l'option <i>--rebase</i> à la commande <i>git pull</i> :</p>

<pre>git pull --rebase</pre>

</div>

La commande `git fetch` permet de récupérer les modifications depuis le remote, c'est-à-dire depuis le serveur _git_ distant dans la plupart des cas.
Les modifications sont récupérées et sont stoquées dans le dossier `.git` mais elles ne sont pas appliquées. 
Vous pouvez par exemple voir ce qui a été poussé par vos collègues avant de les appliquer à votre espace de travail à l'aide des commandes `git log` et `git diff` 
ou bien en créant une nouvelle branche locale à partir de leurs commits.

Le rôle de `git merge` ou `git rebase` est alors d'appliquer les modifications récupérées avec la commande `git fetch` à votre espace de travail.

Comme son nom l'indique, `git merge` permet de merger deux branches en créant un nouveau commit.
Supposons que nous ayons les deux branches `dev`et `master` suivantes et que nous voulions merger la branche `dev` dans la branche `master`.

	* 6f36e0b (dev) Thrid modification on branch dev
	* ffa8732 Second modification on branch dev
	* 95a09fc First modification on branch dev
	| * 8d8885d (HEAD -> master, origin/master) Modify the third file
	| * 3a152d8 Modify the second file
	| * d101b26 Add a third file
	| * 025fc2c Add a second file
	|/
	* c8324c9 Modify file1.txt
	* 46db71c add file1.txt

Après avoir taper la commande `git merge dev` depuis la branche `master`, on obtient le graphe suivant montrant la création d'un nouveau commit `83b1c98` sur la branche `master` :

	*   83b1c98 (HEAD -> master) Merge branch 'dev'
	|\
	| * 6f36e0b (dev) Thrid modification on branch dev
	| * ffa8732 Second modification on branch dev
	| * 95a09fc First modification on branch dev
	* | 8d8885d (origin/master) Modify the third file
	* | 3a152d8 Modify the second file
	* | d101b26 Add a third file
	* | 025fc2c Add a second file
	|/
	* c8324c9 Modify file1.txt
	* 46db71c add file1.txt	


<div class="note">
<!--img src="/assets/images/common/tip.png" height="42" width="42"/--><h1>Note</h1>

<p>Par défaut, lors d'un <i>merge</i>, si <i>git</i> le peut, il fera un <i>fast-forward</i> ce qui est assimilable à un <i>rebase</i>. 
Ce comportement est désactivable avec l'option <code>--no-ff</code> de la commande <code>git merge</code>. 
Nous en rediscuterons plus bas mais nous considérons ici que c'est cas pour simplifier la compréhension.</p>

</div>

Maintenant faisons la même chose avec un _rebase_ :

	* 1fcff4e (HEAD -> master) Modify the third file
	* d52a178 Modify the second file
	* a373ff3 Add a third file
	* ea6a6ef Add a second file
	* 6f36e0b (dev) Thrid modification on branch dev
	* ffa8732 Second modification on branch dev
	* 95a09fc First modification on branch dev
	* c8324c9 Modify file1.txt
	* 46db71c add file1.txt

Lors d'un _rebase_, _git_ commence par repérer le dernier commit commun aux deux branches (ici le commit `c8324c9`).
Ensuite il applique les commits de la branche sur laquelle on veut se "rebaser" (ici la branch `dev`). 
Ainsi, les commits `95a09fc`, `ffa8732` et `6f36e0b` sont appliqués.
Enfin, les commits de la branche sur laquelle on est (ici `master`) sont appliqués. 


<div class="note">
<!--img src="/assets/images/common/tip.png" height="42" width="42"/--><h1>Note</h1>

<p>Avez-vous remarqué quelque chose de particulier concernant les commits de la branche <i>master</i> qui ont été appliqués ?
Et si je vous donne en plus du log précédent, le log de la branch remote <i>origin/master</i> ?</p>

<pre>
	* 1fcff4e (HEAD -> master) Modify the third file
	* d52a178 Modify the second file
	* a373ff3 Add a third file
	* ea6a6ef Add a second file
	* 6f36e0b (dev) Thrid modification on branch dev
	* ffa8732 Second modification on branch dev
	* 95a09fc First modification on branch dev
	| * 8d8885d (origin/master) Modify the third file
	| * 3a152d8 Modify the second file
	| * d101b26 Add a third file
	| * 025fc2c Add a second file
	|/
	* c8324c9 Modify file1.txt
	* 46db71c add file1.txt
</pre>

<p>Et oui, <i>git</i> a créé des nouveaux commits !</p>

</div>





## OK mais alors, faut-il utiliser `git merge` ou `git rebase` ?

C'est là que je lance un troll et que je vais déclencher les foudres des _pro-merges_ et des _pro-rebases_.
Plus sérieusement, dans cette section je vais vous donner ma vision des choses dans 3 cas usuels : la récupération des commits du _remote_, le rapratriement des modifications d'une _feature_ dans la branche principale de _dev_ et inversement la récupération des commits de la branche de principale de _dev_ pour le développement de votre feature. Cependant les choix peuvent différer suivant le workflow utilisé, les règles imposés par l'équipe ou encore la difficulté du merge à effectuer. 

Bon tout d'abord, regardez le dernier log ci-dessus.
Que se passerait-il si on décidait de pousser le _rebase_ que l'on a fait ?

Si vous décidiez de pousser le _rebase_ précédent git vous rejètera car vous voulez changer l'historique.
C'est néanmoins possible avec l'option `-f` de la command `git push` mais c'est ***fortement déconseillé***.

Ainsi, la première règle à respecter est de ne pas faire de _rebase_ si cela modifie l'historique de repository _remote_.
Contrairement au _merge_, un _rebase_ change l'historique et ne peut donc pas être appliquer dans tous les cas.
C'est notament pour cette raison que certains refusent de faire des _rebase_ pour ne pas modifier l'historique.


### Cas de la récupération des modifications du _remote_

Prenons maintenant le cas le plus courant, celui de la récupération des modifications du _remote_.
Supposons que tous les développeurs fassent des _merges_ (ou des _pull_ avec la configuration par défaut comme c'est souvent le cas) pour récupérer les _commits_ du _remote_.

Partons d'une branche de développement avec 3 commits :

![git merge 1](../../../../assets/images/git-merge-rebase/git-merge_1.png "git merge 1"){: .center-image}
 
Supposons que 2 développeurs partent du même commit n°3 pour commencer leur développement.
Le premier développeur va commiter deux modifications en local : 

![git merge 2](../../../../assets/images/git-merge-rebase/git-merge_2.png "git merge 2"){: .center-image}

Avant de pouvoir pousser ses modifications sur le _remote_, il va devoir récupérer les modifications du _remote_.
Si ce développeur utilise un _merge_ ou un _pull_ (configuration par défaut) et supposant qu'il y ait eu des modifications sur le _remote_ entretemps (ou bien que le _fast-forward_ soit désactivé),
il aura un historique semblable à celui-là :

![git merge 3](../../../../assets/images/git-merge-rebase/git-merge_3.png "git merge 3"){: .center-image}


Maintenant, prenons notre second développeur.
Ce dernier veut également pousser 2 commits :

![git merge 4](../../../../assets/images/git-merge-rebase/git-merge_4.png "git merge 4"){: .center-image}

Si lui aussi récupère les modifications du _remote_ avec un _merge_ ou un _pull_, il va se retrouver avec l'historique suivant :

![git merge 5](../../../../assets/images/git-merge-rebase/git-merge_5.png "git merge 5"){: .center-image}

Et si on ajoute un troisième développeur ?

![git merge 7](../../../../assets/images/git-merge-rebase/git-merge_7.png "git merge 7"){: .center-image}

Bon vous avez compris, l'historique peut vite devenir incompréhensible.
Et j'ai considéré un cas relativement simple avec des développements qui commencent depuis le même commit.
Mais si par exemple un _merge_ avait été fait par un quatrième développeur depuis le commit n°6, je vous laisse imaginer le bazard...


Et si tous ces développeurs avaient fait des _rebases_ plutôt, que ce serait-il passer ?
Avant de pousser leurs modifications, chacun des développeurs auraient récupérés les commits du _remote_ et auraient ensuite appliqué les leurs.
Cela nous aurait donné l'historique suivant :

![git rebase](../../../../assets/images/git-merge-rebase/git-rebase.png "git rebase"){: .center-image}

Je ne sais pas vous mais je trouve ça plus clair !

<div class="note">
<!--img src="/assets/images/common/tip.png" height="42" width="42"/--><h1>Note</h1>

<p>Il y a quand même un détail à savoir et qui peut avoir son importance.

Lorsque vous faites un <i>merge</i>, vous allez peut-être être amené à résoudre des conflits sur un ou plusieurs fichiers mais pour un fichier donné, vous n'aurez à résoudre des conflits qu'une seule fois. 

Ce n'est pas le cas lorque vous faites un <i>rebase</i>. Comme vos commits sont appliqués un à un, vous serez amené peut-être à résoudre des conflits plusieurs fois de suite sur un même fichier.</p>

<p>Afin d'éviter ça, il est recommandé de faire des <i>rebases</i> fréquemment.</p>
</div>

### Cas du développement d'une _feature_

Lors du développement d'une _feature_, il est d'usage de créer une nouvelle branche pour faire ses développements avant de les pousser sur la branche de développement commune.
Considérons l'historique suivant :

![git merge 8](../../../../assets/images/git-merge-rebase/git-merge-8.png "git merge 8"){: .center-image}

Lorsque le développement de la _feature_ est terminé, pour mettre ses modifications dans la branche de développement, le développeur peut donc, depuis la branche _dev_, faire soit un _rebase_, soit un _merge_.

Supposons qu'il fasse un _rebase_, on aurait donc l'historique suivant :

![git rebase 2](../../../../assets/images/git-merge-rebase/git-rebase-2.png "git rebase 2"){: .center-image}

Il y a un problème mineure et un problème majeur avec cette méthode.

Tout d'abord, en faisant comme ça, tous les commits de la branche _feature_ feront partie de la branche principale de développement _dev_ ce qui n'est pas forcément ce que l'on souhaite.
Il est préférable à mon sens d'avoir sur la branche _dev_ un seul commit correspondant à l'implémentation de la _feature_, quitte à garder le détail des commits de la _feature_ dans une branche séparée (en la poussant sur le _remote_).

Mais le point le plus problématique est le point que j'ai évoqué plus haut, c'est-à-dire que si le commit "6" ait été poussé sur le _remote_, avec cette méthode, on ne pourrait pas pousser la branche de _dev_ sur le _remote_ à moins que l'on force le _push_.

Vous avez compris, dans ce cas précis, je préconise plutôt de faire un _merge_ ce qui nous donnera l'historique suivant :

![git merge 9](../../../../assets/images/git-merge-rebase/git-merge-9.png "git merge 9"){: .center-image}

Ainsi, la branche _dev_ n'aura qu'un seul commit correspondant à votre _feature_ et ne sera donc pas poluée par tous les petits commits que vous auriez pu faire du développement.
Et si tout fois, vous souhaitez garder l'historique du développement de votre _feature_, rien ne vous empêche de pousser votre branche sur le _remote_.


### Cas de la récupération des commits de la branche _dev_ pour le développement de votre _feature_

Considérons à présent le cas inverse, vous avez commencé le développement de votre _feature_ mais l'un de vos collègues a commité une modification sur la branche de _dev_ que vous avez besoin de récupérer pour le développement de votre _feature_.

![git merge 8](../../../../assets/images/git-merge-rebase/git-merge-8.png "git merge 8"){: .center-image}

Supposons que vous ayez l'historique précédent, cela revient donc à récupérer le commit "6" sur la branche _feature_.

Il y a deux cas de figure : le cas où votre branche _feature_ est poussée sur le _remote_ et celui où votre branche _feature_ n'est qu'en local dans votre espace de travail. 

Dans le premier cas, si vous avez bien suivi ce que j'ai dit plus haut vous ne pouvez pas faire de _rebase_.

![git rebase 3](../../../../assets/images/git-merge-rebase/git-rebase-3.png "git rebase 3"){: .center-image}

Vous voyez donc dans ce cas d'un _rebase_ modifierait l'historique et il sera impossible de pousser sur le _remote_ à moins de forcer le _push_.
Dans ce cas, il faudra plutôt utiliser un _merge_.

![git merge 10](../../../../assets/images/git-merge-rebase/git-merge-10.png "git merge 10"){: .center-image}

Dans le second cas, c'est-à-dire le cas où votre branche _feature_ n'est qu'en local, je recommande plutôt de faire un _rebase_. L'historique sera plus clair puisque ce sera comme si vous aviez commencé votre branche _feature_ un (ou plusieurs) commit plus tard.

![git rebase 4](../../../../assets/images/git-merge-rebase/git-rebase-4.png "git rebase 4"){: .center-image}

## Conclusion

J'ai présenté dans cet article trois cas de figure très courants dans un processus de développement et donné pour chacun d'eux ce que je préconiserais.
Cependant, comme je l'ai évoqué plus haut, il y a souvent des cas un peu plus complexes qui ne sont pas aussi simples à régler. 
Le plus important à mon sens est d'abord de bien comprendre la différence entre un _rebase_ et un _merge_ et savoir comment sera votre historique après avoir appliqué l'une ou l'autre méthode.
Il est aussi important de définir et respecter le même process au sein d'une même équipe.
Enfin, certains préfèrent ne jamais modifier l'historique pour par exemple garder la cohérence chronologique des commits. 
Je comprends cette logique mais pour ma part je préfère avoir un historique clair et le plus linéaire possible.

Je finirai cette article par rappeler qu'avec _git_ vous pouvez toujours essayer un _merge_ ou un _rebase_ et revenir en arrière si ça ne vous convient pas.
Tant que vous n'avez pas poussé, vous pourrez annuler vos modifications et recommencer.
