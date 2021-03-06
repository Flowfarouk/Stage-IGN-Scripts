# Fusion by classification
# Modèle: Selection de 10000 pixels a partir de 5 dalles  (im_39000_40000,im_39000_42000,im_41000_30000,im_41000_40000,im_41000_42000) et apprentissage
directory
DIR_EXES=~/DeveloppementBase/Scripts/exes # Executables directory
#IMAGES="im_39000_40000,im_39000_42000,im_41000_30000,im_41000_40000,im_41000_42000"
IMAGES="im_24500_18500 im_26500_18500 im_24500_20500 im_26500_20500 im_28500_32500 im_30500_30500"
REGION=gironde

cd /media/cyrilwendl/15BA65E227EC1B23/$REGION/detail

# parallelize: bash file with commands
rm makefiletmp bashtmp.sh
rm -Rf ./fusion_classif && mkdir ./fusion_classif
rm -Rf ./fusion_classif/appart && mkdir ./fusion_classif/appart
touch bashtmp.sh

# a. RF
echo "$DIR_EXES/Classifieur EstimateModel --cc $IMAGES -d classification.train.datatype=labelimage -d classification.train.path=%s/train_tout.rle -d selectvtp.nbechantillonsmax=10000 -d canaux.path=%s/proba_S2.tif,%s/proba_SPOT6.tif -d classification.algorithm=opencv.rf -d classification.model.path=./fusion_classif/model_rf" >> bashtmp.sh

# b. SVM (t2)
# svm a noyau rbf
echo "$DIR_EXES/Classifieur EstimateModel --cc $IMAGES -d classification.train.datatype=labelimage -d classification.train.path=%s/train_tout.rle -d selectvtp.nbechantillonsmax=500 -d canaux.path=%s/proba_S2.tif,%s/proba_SPOT6.tif -d classification.algorithm=libsvm.csvm -d classification.train.libsvm.t=2 -d  classification.train.libsvm.optimiser=true -d classification.train.libsvm.b=1  -d classification.model.path=./fusion_classif/model_svmt2" >> bashtmp.sh

# c. SVM (t0)
# svm a noyau lineaire
echo "$DIR_EXES/Classifieur EstimateModel --cc $IMAGES -d classification.train.datatype=labelimage -d classification.train.path=%s/train_tout.rle -d selectvtp.nbechantillonsmax=10000 -d canaux.path=%s/proba_S2.tif,%s/proba_SPOT6.tif -d classification.algorithm=libsvm.csvm -d classification.train.libsvm.t=0  -d classification.train.libsvm.b=1 -d classification.model.path=./fusion_classif/model_svmt0" >> bashtmp.sh

$DIR_EXES/Bash2Make bashtmp.sh makefiletmp # MakeFile compilation
make -f makefiletmp -j 3
rm makefiletmp bashtmp.sh
