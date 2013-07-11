SpellsTracker
=============

By *Relena*

Ce module enregistre tous les sorts lancé au cours du combat et les rend accessible dans son interface.

Les sorts sont trié par lanceur, tour de lancement et ordre de lancement.

!["infobulle du premier sort lancé par un monstre au tour 8"](http://img145.imageshack.us/img145/639/1objuct2.png "infobulle du premier sort lancé par un monstre au tour 8")

Une vidéo de présentation du module est visualisable sur la chaine Youtube [DofusModules](https://www.youtube.com/user/dofusModules "Youtube, DofusModules"):

[Lien vers la vidéo](https://www.youtube.com/watch?v=QCbPwEKUqrE "Vidéo de présentation du module")

Download + Compile:
-------------------

1. Install Git
2. git clone https://github.com/Dofus/SpellsTracker.git
3. mxmlc -output SpellsTracker.swf -compiler.library-path+=./modules-library.swc -source-path src -keep-as3-metadata Api Module DevMode -- src/SpellsTracker.as

Installation:
=============

1. Create a new *SpellsTracker* folder in the *ui* folder present in your Dofus instalation folder. (i.e. *ui/SpellsTracker*)
2. Copy the following files in this new folder:
    * xml/
    * assets/
    * css/
    * SpellsTracker.swf
    * Relena_SpellsTracker.dm
3. Launch Dofus
4. Enable the module in your config menu.
5. ...
6. Profit!
