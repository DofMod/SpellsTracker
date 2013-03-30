import xml.dom.minidom
import shutil
import os
import os.path as op

moduleName = "SpellsTracker"
moduleDmName = "Relena_" + moduleName + ".dm"
moduleSwfName = moduleName + ".swf"
moduleXmlName = "xml"
moduleCssName = "css"
moduleAssetsName = "assets"

srcPath = "."
dstPath = op.normpath(op.join(os.environ['PROGRAMFILES(X86)'], "Dofus2Beta/app/ui", moduleName))

def upVersion(fileDmPath):
	dom = xml.dom.minidom.parse(fileDmPath)

	versionNumbers = dom.getElementsByTagName("version")[0].firstChild.data.split('.')
	versionNumbers[1] = str(int(versionNumbers[1]) + 1)

	dom.getElementsByTagName("version")[0].firstChild.data = '.'.join(versionNumbers)

	with open(fileDmPath, encoding='utf-8', mode='w') as file:
		dom.writexml(file)

upVersion(op.normpath(op.join(srcPath, moduleDmName)))

shutil.copyfile(op.normpath(op.join(srcPath, moduleDmName)), op.normpath(op.join(dstPath, moduleDmName)))
shutil.copyfile(op.normpath(op.join(srcPath, moduleSwfName)), op.normpath(op.join(dstPath, moduleSwfName)))
shutil.rmtree(op.normpath(op.join(dstPath, moduleXmlName)), 1)
shutil.copytree(op.normpath(op.join(srcPath, moduleXmlName)), op.normpath(op.join(dstPath, moduleXmlName)))
shutil.rmtree(op.normpath(op.join(dstPath, moduleCssName)), 1)
shutil.copytree(op.normpath(op.join(srcPath, moduleCssName)), op.normpath(op.join(dstPath, moduleCssName)))
shutil.rmtree(op.normpath(op.join(dstPath, moduleAssetsName)), 1)
shutil.copytree(op.normpath(op.join(srcPath, moduleAssetsName)), op.normpath(op.join(dstPath, moduleAssetsName)))