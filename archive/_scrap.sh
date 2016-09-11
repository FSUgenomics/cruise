INSTALL CUSTOM GENOME
cd /gbdb
mkdir b73v3

GENOME="zeaMay3"
faToTwoBit genome.fa genome.2bit
twoBitInfo genome.2bit stdout | awk '{printf "%s\t%s\t/gbdb/${GENOME}/genome.2bit\n", $1,$2}' > chromInfo.tab

BLAT
use hgcentral;
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("b73v2", "leopold.iplantcollaborative.org",17777,0,1);
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("b73v2", "leopold.iplantcollaborative.org",17778,1,0);
exit


IDEOGRAM
# edit /gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh with the following lines ##########
# set sql=/gbdb/kent/src/hg/lib/cytoBandIdeo.sql
# source /gbdb/kent/src/utils/qa/qaConfig.csh
#######################################################################################
~/software/kent/src/utils/qa/makeCytoBandIdeo.csh
# add to trackDb.ra ###################################################################
track cytoBandIdeo
shortLabel Chromosome Band (Ideogram)
longLabel Ideogram for Orientation
group map
visibility dense
type bed 4 +
#######################################################################################
hgTrackDb ./ b73v2 trackDb /gbdb/kent/src/hg/lib/trackDb.sql ./




####################### BLAT BOOTUP ################################
cd /gbdb/b73v2
gfServer -tileSize=7 -canStop start leopold.iplantcollaborative.org 17777 -stepSize=5 b73v2.2bit &
gfServer -trans -canStop start leopold.iplantcollaborative.org 17778 b73v2.2bit &




make tracks searchable

hgLoadBed b73v2 hitdomain /gbdb/b73v2/bbi/hitdomain.bed
hgFindSpec . b73v2 hgFindSpec /gbdb/kent/src/hg/lib/hgFindSpec.sql .
hgTrackDb ./ b73v2 trackDb /gbdb/kent/src/hg/lib/trackDb.sql ./

scrap

# awk '{print $1,0,$2,$1,"gpos"}' OFS='\t' b73v2.chrom.sizes > cytoBand.txt #use script instead
# hgsql b73v2 < /gbdb/kent/src/hg/lib/cytoBandIdeo.sql
# hgsql b73v2 -e 'load data local infile "/gbdb/b73v2/cytoBand.txt" into table cytoBandIdeo;'


INSERT grp VALUES("user", "Custom Tracks", 1);
INSERT grp VALUES("map", "Mapping and Sequencing Tracks", 2);
INSERT grp VALUES("genes", "Genes and Gene Prediction Tracks", 3);
INSERT grp VALUES("pubs", "Literature", 3.5);
INSERT grp VALUES("rna", "mRNA and EST Tracks", 4);
INSERT grp VALUES("regulation", "Expression and Regulation", 5);
INSERT grp VALUES("compGeno", "Comparative Genomics", 6);
INSERT grp VALUES("varRep", "Variation and Repeats", 7);
INSERT grp VALUES("x", "Experimental Tracks", 10);

BLAT
use hgcentral;
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("tair10", "leopold.iplantcollaborative.org",17781,0,1);
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("tair10", "leopold.iplantcollaborative.org",17782,1,0);
exit


# edit /gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh with the following lines ##########
# set sql=/gbdb/kent/src/hg/lib/cytoBandIdeo.sql
# source /gbdb/kent/src/utils/qa/qaConfig.csh
#######################################################################################
/gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh
# add to trackDb.ra ###################################################################
track cytoBandIdeo
shortLabel Chromosome Band (Ideogram)
longLabel Ideogram for Orientation
group map
visibility dense
type bed 4 +
#######################################################################################
hgTrackDb ./ tair10 trackDb /gbdb/kent/src/hg/lib/trackDb.sql ./


############### MYSQL PERMISSIONS ################## modified from ex.MySQLUserPerms.sh
