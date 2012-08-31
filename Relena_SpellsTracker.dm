<?xml version="1.0" ?><module>

	<!-- Information sur le module -->
	<header>
		<!-- Nom affiché dans la liste des modules -->
		<name>SpellsTracker</name>
		<!-- Version du module -->
		<version>0.501</version>
		<!-- Dernière version de dofus pour laquelle ce module fonctionne -->
		<dofusVersion>2.8.0</dofusVersion>
		<!-- Auteur du module -->
		<author>Relena</author>
		<!-- Courte description -->
		<shortDescription>Suit les sorts lancés pendant un combat</shortDescription>
		<!-- Description détaillée -->
		<description>Ce module permet de suivre les sorts lancés au cours d'un combat. Il affiche enssuite ces informations dans une petite fenêtre au dessus de la timeline de combat</description>
	</header>

	<!-- Liste des interfaces du module, avec nom de l'interface, nom du fichier squelette .xml et nom de la classe script d'interface -->
	<uis>
		<ui class="ui::SpellButtonContainer" file="xml/SpellButtonContainer.xml" name="SpellButtonContainer"/>
		<ui class="ui::SpellButton" file="xml/SpellButton.xml" name="SpellButton"/>
		<ui class="ui::SpellWindow" file="xml/SpellWindow.xml" name="SpellWindow"/>
		<ui class="ui::SpellsTrackerConfig" file="xml/SpellsTrackerConfig.xml" name="SpellsTrackerConfig"/>
	</uis>
	
	<script>SpellsTracker.swf</script>
	
</module>