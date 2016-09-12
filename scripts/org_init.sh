#!/usr/bin/env bash

# BROWSER DATA SETUP HELPER SCRIPT

# this script should take a google id as the argument on the command line, with the columns:

# gbdbdir (all same)
# database name (for genome)
# file location (can be local or remote, distringuished with ":")

# fasta or 2bit files will be detected by extension and used as the genome 2bit
# 

# RUN THIS ON THE WEB SERVER
wget -brA 'dna_sm.genome.fa.gz' ftp://ftp.ensemblgenomes.org/pub/plants/release-31/fasta/


mkdir -p $nibPath/bbi
mkdir -p $nibPath/html

#curl -so $nibPath/genome.fa.gz $faurl
cp ftp.ensemblgenomes.org/pub/plants/release-31/fasta/$dname/dna/*dna_sm.genome.fa.gz $nibPath/genome.fa.gz

gunzip $nibPath/genome.fa.gz

faToTwoBit $nibPath/genome.fa $nibPath/genome.2bit
twoBitInfo $nibPath/genome.2bit stdout | awk "{printf \"%s\t%s\t$nibPath/genome.2bit\n\", \$1,\$2}" > $nibPath/chromInfo.tab
cut -f 1,2 $nibPath/chromInfo.tab | sort -k1,1 > $nibPath/genome.chrom.sizes
echo -e "track cytoBandIdeo\nshortLabel Chromosome Band (Ideogram)\nlongLabel Ideogram for Orientation\ngroup map\nvisibility dense\ntype bed 4 +" >> $nibPath/trackDb.ra
cat $nibPath/genome.chrom.sizes | awk '{print $1"\t"0"\t"$2"\t""\t""gneg"}' | sort -k1,1 -k2,2n > $nibPath/cytoband.bed


wget -qO- ftp://ftp.ensemblgenomes.org/pub/current/plants/gtf/zea_mays/Zea_mays.AGPv3.31.gtf.gz | gunzip -c | gtfToGenePred /dev/stdin /dev/stdout | genePredToBed /dev/stdin /dev/stdout | sort -k1,1 -k2,2n -k3,3n > $GBDIR/$name/bbi/ensemblGenes.bed
bedToBigBed $GBDIR/$name/bbi/ensemblGenes.bed $GBDIR/$name/genome.chrom.sizes $GBDIR/$name/bbi/ensemblGenes.bb


while IFS=$'\t' read -r $cols
do
  if [ "$ensemblGff" != "NA" && $name != "name" ]
  then
    echo "processing $name"
    mkdir -p ${name}/bbi

    # grab gff
    curl -s ${ensemblGff} | gunzip -c | sed 's/?/\./g' > ${name}/ensemblAnnotations.gff

    # genes
    gffread -T -o- ${name}/ensemblAnnotations.gff | sed 's/transcript://g' | sed 's/gene://g' | awk -F '\t' '{ if($2 != "."){print $0} }' OFS='\t' | gtfToGenePred stdin stdout | genePredToBed stdin stdout > ${name}/ensemblGenes.bed

    # non-simple repeats
    grep 'repeat_region' ${name}/ensemblAnnotations.gff | cut -f 1,4,5,9 | sed 's/Name=//g' | sed 's/class=//g' | sed 's/;repeat_consensus=.*//g' | grep -v 'trf;trf' | grep -v 'dust;dust' | sort -k1,1 -k2,2n -k3,3n > ${name}/ensemblRepeats.bed
    bedToBigBed ${name}/ensemblRepeats.bed ${name}/genome.chrom.sizes ${name}/bbi/ensemblRepeats.bb
    # trf
    grep 'repeat_region' ${name}/ensemblAnnotations.gff | grep 'Name=trf' | cut -f 1,4,5 | sort -k1,1 -k2,2n -k3,3n > ${name}/bbi/ensemblTrfs.bed
    bedToBigBed ${name}/ensemblRepeats.bed ${name}/genome.chrom.sizes ${name}/bbi/ensemblTrfs.bb

    # dust
    grep 'repeat_region' ${name}/ensemblAnnotations.gff | grep 'Name=dust' | cut -f 1,4,5 | sort -k1,1 -k2,2n -k3,3n > ${name}/bbi/ensemblDust.bed
    bedToBigBed ${name}/ensemblRepeats.bed ${name}/genome.chrom.sizes ${name}/bbi/ensemblDust.bb


  fi
done < "$genomesfile"















RepeatMasker -species $genus -pa 25 -gff $fa

rclasses=($(tail -n+4 $rmout | awk '{print $11}' | sort | uniq))

echo -e "track repeatmasker\nshortLabel RepeatMasker\nlongLabel Repeating Elements by RepeatMasker\ntype bigBed 4\ncompositeTrack on\nvisibility dense\nallButtonPair on\ndragAndDrop on\n\n" > /gbdb/$name/trackDb.tmp

for curclass in ${rclasses[*]}
do
    curclassname=$(echo $curclass | tr /\? _)
    bedname=/gbdb/$name/$(basename $rmout | sed -r 's/\.[[:alnum:]]+\.[[:alnum:]]+$//')_repeats_"$curclassname".bed
    bwname=/gbdb/$name/$(basename $rmout | sed -r 's/\.[[:alnum:]]+\.[[:alnum:]]+$//')_repeats_"$curclassname".bw
    echo $curclass
    echo $curclassname
    echo $bedname
    echo $bwname
    echo "awk -v curclass=$curclass '{if ($11==curclass) print $5,$6,$7,$10}' OFS='\t' $rmout > $bedname"
    awk -v curclass=$curclass '{if ($11==curclass) print $5,$6,$7,$10}' OFS='\t' $rmout > $bedname
    echo "bedToBigBed $bedname /gbdb/"$name"/genome.chrom.sizes $bwname"
    bedToBigBed $bedname /gbdb/"$name"/genome.chrom.sizes $bwname
    echo "echo -e "track repeatmasker_"$curclassname"\nshortLabel $curclass\nlongLabel $curclass elements by RepeatMasker\nparent repeatmasker\ntype bigBed 4\nvisibility dense\n\n" >> /gbdb/$name/trackDb.tmp"
    echo -e "track repeatmasker_"$curclassname"\nshortLabel $curclass\nlongLabel $curclass elements by RepeatMasker\nparent repeatmasker\ntype bigBed 4\nvisibility dense\n\n" >> /gbdb/$name/trackDb.tmp
    echo "hgBbiDbLink $name repeatmasker_"$curclassname" $bwname"
    hgBbiDbLink $name repeatmasker_"$curclassname" $bwname


done

cat /gbdb/$name/trackDb.tmp >> /gbdb/$name/trackDb.ra
hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name
