##compare drug targets with metaViper prots

require(synapser)
synLogin()
synQuery="SELECT * FROM syn18460033 WHERE ( ( padj BETWEEN '8.401022050521E-25' AND '0.00001' ) )"

##get github stuff
##get our pcsf
##get fendR
