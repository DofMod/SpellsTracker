<?xml version="1.0" ?><module>

    <!-- Information sur le module -->
    <header>
        <!-- Nom affiché dans la liste des modules -->
        <name>SpellsTracker</name>        
        <!-- Version du module -->
        <version>0.106</version>
        <!-- Dernière version de dofus pour laquelle ce module fonctionne -->
        <dofusVersion>2.6.0</dofusVersion>
        <!-- Auteur du module -->
        <author>Relena</author>
        <!-- Courte description -->
        <shortDescription/>
        <!-- Description détaillée -->
        <description/>
	</header>

    <!-- Liste des interfaces du module, avec nom de l'interface, nom du fichier squelette .xml et nom de la classe script d'interface -->
    <uis>
        <ui class="ui::SpellButtonContainer" file="xml/SpellButtonContainer.xml" name="SpellButtonContainer"/>
		<ui class="ui::SpellButton" file="xml/SpellButton.xml" name="SpellButton"/>
    </uis>
    
    <script>SpellsTracker.swf</script>
    
</module>