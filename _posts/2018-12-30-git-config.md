---
layout: post
title:  Git config
author: Fabrice Fontenoy
categories: [ Git ]
image: assets/images/git-config/git-config.png
description: Cet article explique comment fonctionne la configuration git et donne quelques clefs de configuration utiles
comments: false
---

## À quoi sert la configuration _git_ ?

La configuration _git_ sert à définir des comportements par défaut concernant certaines commandes de _git_.
C'est également dans la configuration _git_ que sont définies les branches locales et remotes. 
Cet article ne traite pas de ce dernier point puisque les branches ne sont pas configurées avec la commande `git config`. 

Parmi les comportements par défaut que l'on peut configurer, on peut citer par exemple :
* les informations de l'utilisateur utilisées lors des commits (nom et email)
* la façon de pousser les branches (toutes les branches modifiées, uniquement la branche courante...)
* le comportement de `git pull` (cf. [article sur git rebase/merge/pull]({{ site.baseurl }}{% post_url 2018-10-14-git-rebase-merge-pull %}))
* la définition d'alias
* l'éditeur par défaut
* l'outil de merge par défaut pour résoudre les conflits
* la sauvegarde ou non des mots de passe
* ...

## Comment fonctionne la configuration de _git_ ?

_Git_ fournit 3 niveaux de configuration : 
* le niveau répertoire - Il s'agit de la configuration au niveau de l'espace de travail local, applicable que dans le répertoire courant. Cette configuration est lue et écrite dans le fichier `.git/config` situé dans le répertoire _git_ courant,
* le niveau utilisateur - Il s'agit de la configuration applicable pour l'ensemble des espaces de travail _git_ de l'utilisateur. Cette configuration est lue et écrite dans le fichier `~/.gitconfig`,
* le niveau système - Il s'agit de la configuration applicable pour tout le système. Cette configuration est lue et écrite dans le fichier `/etc/gitconfig`.

S'il y a un conflit de configuration entre deux niveaux différents, la configuration applicable est la configuration du niveau le plus restrictif. Par exemple, si une clef de configuration est définie à la fois au niveau système et au niveau utilisateur, alors la configuration applicable est la configuration du niveau utilisateur.


## Comment modifier la configuration de _git_ ?
 
Pour modifier la configuration de _git_, vous avez deux solutions : soit vous utilisez la commande `git config` (recommandé), soit vous éditez directement l'un des fichiers cités plus haut.

Il est recommandé d'utiliser la commande `git config` plutôt que d'éditer directement le fichier de configuration afin d'éviter toute erreur d'édition. Cependant, si vous souhaitez récupérer un morceaux de configuration d'une autre configuration _git_ (par exemple, pour récupérer les alias que votre collègue a défini), il est alors plus rapide d'éditer le fichier et de copier-coller les bouts de configuration que vous souhaitez récupérer.

Le format du fichier de configuration est plutôt immédiat.
Si par exemple vous ajouter un alias en utilisant la commande `git config --global alias.st status` alors _git_ ajoutera alors la ligne suivante dans votre fichier de configuration :

	[alias]
		st = status

Ce qui est entre crochet représente la catégorie de la configuration (ex. alias, user, pull, ...). Si la catégorie est déjà présente dans votre fichier de configuration, _git_ n'ajoutera uniquement que la seconde ligne dans la catégorie _[alias]_ déjà présente dans votre fichier de configuration.

## Quelques clefs de configuration bien utiles

Cette section va vous donner quelques exemples de clefs de configuration que vous pouvez utiliser mais il en existe beaucoup d'autres.
Pour avoir une liste plus complète des clefs de configuration, je vous conseille de taper la commande `git config --help`. 
Vous trouverez la liste des clefs de configuration dans la section _Variables_ de l'aide.

### Configuration des données utilisateurs

La configuration des données utilisateurs sont nécessaires pour pouvoir commiter.
Ces clefs de configuration sont généralement configurées au niveau utilisateur pour ne pas à avoir à les redéfinir pour chaque projet.

*	`git config --global user.name "Fabrice Fontenoy"`

	Configure le nom de l'utilisateur. Ce nom est alors utilisé pour tous les commits effectués

*	`git config --global user.email fabrice.fontenoy@true-lines.com`

	Configure l'adresse mail de l'utilisateur. Cette adresse est alors utilisé pour tous les commits effectués


### Configuration des alias

Les alias permettent de remplacer une commande _git_ par une autre commande, généralement plus courte afin d'optimiser l'utilisation de _git_ et rendre son utilisation plus rapide.
Cette section liste un ensemble d'alias bien pratique pour moi mais libre vous de définir ceux qui vous semble le plus appropriés à votre usage de _git_. 

*	`git config --global alias.st status`

	`git st` affichera alors le statut _git_ du répertoire _git_ courant.

*	`git config --global alias.ci commit`

	`git ci` commitera alors les fichiers indexés de répertoire _git_ courant. Il est tout à fait possible d'ajouter l'option `-m "Mon message de commit"' à la suite de la commande `git ci` pour directement préciser le message de commit sans passer par un éditeur de texte.

*	`git config --global alias.co checkout`

	`git co` checkoutera ce que vous précisez après la commande. Par exemple, `git co master` checkoutera la branch _master_.

*	`git config --global alias.br "branch --all"`

	`git br` affichera l'ensemble des branches locales et distantes du répertoire _git_ courant.

*	`git config --global alias.wc "diff-tree --name-status --no-commit-id -r"`

	`git wc` (_wc_ pour _what changed_) affichera la liste des fichiers modifiés par le commit donné en paramètre et leur statut. Par exemple, `git wc HEAD` donnera la liste des fichiers modifiés par le dernier commit.

*	`git config --global alias.lg "log --oneline --all --decorate --graph"`

	`git lg` affichera les logs sous forme de graphe, une ligne par commit, en incluant toutes les branches et en faisant apparaitre les branches distantes ainsi que les tags. Pour moi, il s'agit de l'alias et même la commande _git_ la plus importante car elle permet à tout moment de comprendre en une seule commande où on est, d'où vient la branche sur laquelle on est et quelle est sont avancée par rapport à la branche distante.   

### Autres clefs de configuration

Cette section liste quelques autres clefs de configuration que j'ai l'habitude de configurer.

*	`git config --global pull.rebase true

	De base, lorsque vous faites un `git pull`, _git_ fait un `git fetch` suivi d'un `git merge`. Si vous avez lu [mon article sur git rebase/merge/pull]({{ site.baseurl }}{% post_url 2018-10-14-git-rebase-merge-pull %}) (et j'en suis sûr :-) ), il est souvent préférable de faire un _rebase_ plutôt qu'un _merge_. Cette clef de configuration permet alors à la commande `git pull` d'effectuer un _rebase_ à la _place_ d'un merge.

*	`git config --global core.editor vim`

	Cette clef de configuration permet de configuration l'éditeur par défaut qui est lancé par exemple lorsque vous faites un commit sans l'option `-m`.

*	`git config core.fileMode false`

	Cette clef de configuration permet de préciser à _git_ d'ignorer les modes d'accès aux fichiers (lecture, écriture, exécution). Cela est nécessaire par exemple si les membres de votre équipe développent sur des OS différents. Les modes d'accès pouvant avoir son importance, il est sans doute préférable de configurer cette clef au niveau des répertoires _git_ uniquement.

*	`git config --global credential.helper store`

	Cette clef de configuration permet de dire à _git_ de retenir les mots de passe d'accès aux répertoires distants pour ne pas à avoir à les retaper à chaque _fetch_ ou _push_. 

*	`git config --global push.default current`

	Cette clef de configuration permet, lors d'un _push_, de dire à _git_ de pousser la branche sur le répertoire distant spécifié dans une branche de même nom, peu importe d'où vient la branche, i.e. sans que l'_upstream_ soit nécessairement spécifié pour cette branche (contrairement à la valeur par défaut qui est _simple_).


*	`git config --global merge.tool meld`

	Cette clef de configuration permet de configurer l'outil de merge par défaut à utiliser lors de la résolution de conflits avec la méthode `git mergetool`. Dans le cas présent, l'outil _meld_ sera exécuté.

## Conclusion

Nous avons vu dans cette article les bases de la configuration _git_ et nous avons vu quelques exemples de clefs de configuration.
Beaucoup d'autres clefs de configuration existent néanmoins. N'hésitez pas à consulter la page d'aide de `git config` pour trouver une clef de configuration en particulier ou bien si vous avez des problèmes d'insomnies :-). 
