# Saves evaluation numbers of all classifications in ./Eval
# bash eval.sh [tile] ; done	
bold=$(tput bold)
normal=$(tput sgr0)
cd $DIR_SAVE
SUBFOLDER="Fusion_all_weighted"

rm -rf ./Eval
mkdir ./Eval

FNAME=./Eval/eval.txt
rm -rf $FNAME

GT="train_tout.rle"

# convert rf, svm, svmt0 and GT to 5cl labels
cd $DIR_SAVE
BASE=Fusion_all_weighted/Classified/classif_Fusion_
for file in train_tout ${BASE}rf ${BASE}svmt0 ${BASE}svmt2 Regul/regul_svmt2_G2_l1000_g70_e500_0_0_0; do
	continue;
	Ech_noif Format $file.rle $file.tif # create tif for gdal_calc.py
	gdal_calc.py -A $file.tif --calc="A*(A<6)" --outfile="${file}_5cl.tif" # convert class 6 -> class 0
	rm $file.tif # create tif for gdal_calc.py
	Ech_noif Format ${file}_5cl.tif $file.rle # create tif for gdal_calc.py # convert back (overwrite) rle
done

# Evaluation
HDR="Methode Kappa OA AA Fmoy F_bat"
echo $HDR >> $FNAME
for CLASSIFICATION_DIR in ./Classified ./$SUBFOLDER/Classified ./Fusion_all/Classified ./Regul ; do #./Walid 
	for i in $CLASSIFICATION_DIR/*.rle ; do
		CLASSIF_NAME=${i%.rle}
		CLASSIF_NAME=${CLASSIF_NAME##*/}
		echo -n "${CLASSIF_NAME##classif_Fusion_} " >> $FNAME
		$DIR_EXES/Eval $i $GT ./Eval/bm_$CLASSIF_NAME.rle $DIR_BASH/tools/legende.txt ./Eval/cf_$CLASSIF_NAME.txt --Kappa --OA --AA --FScore_moy --FScore_classe 1 >> $FNAME
	done
done


# output eval.txt
for a in "$@"
	do
	ACTION=FALSE
	if [ "$a" = "r" ]; then
		# Add ranks
		array=( 2 3 4 5 6 )
		array2=( "K" "OA" "AA" "Fmoy" "FBat" )
		for ((i=0;i<${#array[@]};++i)); do
			cat Eval/eval.txt | sort -k${array[i]} -r | awk -v var=${array2[i]}\_rank 'BEGIN { FS = " " } ; NR==1{$0=($0 FS var)};NR>1{$0=($0 FS 	FNR-1)} ; {print $0}' >> $FNAME-1
			mv $FNAME-1 $FNAME    
		done
		cat Eval/eval.txt | tr -s '[:space:]' | awk -v var="rank_moy" 'BEGIN { FS = " " } ; NR==1{$0=($0 FS var)};NR>1{$0=($0 FS int(($7+$8+$9+$10+$11)/5))} ; {print $0}' >> $FNAME-1
		mv $FNAME-1 $FNAME
	fi
    if [ "$a" = "K" ]; then
		NAME=K
		NUM=2
		ACTION=TRUE
	elif [ "$a" = "OA" ]; then
		NAME=OA
		NUM=3
		ACTION=TRUE
	elif [ "$a" = "AA" ]; then
		NAME=AA
		NUM=4
		ACTION=TRUE
	elif [ "$a" = "Fmoy" ]; then
		NAME=Fmoy
		NUM=5
		ACTION=TRUE
	elif [ "$a" = "FBat" ]; then
		NAME=FBat
		NUM=6
		ACTION=TRUE
	elif [ "$a" = "Tot" ]; then
    	echo "${bold}Sorted by rank_tot:${normal}"
		NUM=12
		cat $FNAME|  sort -k$NUM -n |column -s ' '  -t
	fi
    if [ "$ACTION" = "TRUE" ]; then
    	echo "${bold}Sorted by $NAME:${normal}"
		cat $FNAME|  sort -k$NUM -r |column -s ' '  -t
    fi
done

#cat ./Eval/eval.txt | cat  column -s ' '  -t >> $FNAME-1
#rm $FNAME
#mv $FNAME-1 $FNAME
