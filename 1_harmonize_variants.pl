#!usr/bin/perl
use strict;
my(@hang,%our,$name1,$name2,$name3,$name4);

############### flip function ###########
sub flip{
my $allele=$_[0];
my $len=length($_[0]);
my $i=0;
my $flip="";

for($i=0;$i<=$len-1;$i++)
 {my $letter=substr($allele,$i,1);
  if($letter eq "A"){$flip.="T";}
  if($letter eq "T"){$flip.="A";}
  if($letter eq "C"){$flip.="G";}
  if($letter eq "G"){$flip.="C";}
  if($letter eq "*"){$flip.="*";}
 }
return $flip;
}
####################


open F1,"<$ARGV[0]"; ### CPH_variants.bim
#1       1:13417:C:CGAGA 0       13417   CGAGA   C
#1       1:13504:G:A     0       13504   A       G
#23      X:156028188:C:G 0       156028188       G       C
#23      X:156028214:C:T 0       156028214       T       C

while(<F1>)
{chomp;
 @hang=split;
 $our{$hang[1]}=1;
}
close F1;

open OUT, ">>$ARGV[2]";  # COPD_Bothsex_inv_var_meta_GBMI_052021_nbbkgt1.newSNPID.txt
open F2,"<$ARGV[1]";    # GBMI-meta-results: COPD_Bothsex_eas_inv_var_meta_GBMI_052021_nbbkgt1.txt
 
#CHR    POS     REF     ALT     rsid    all_meta_AF     inv_var_meta_beta       inv_var_meta_sebeta     inv_var_meta_p  inv_var_het_p   direction       N_case  N_ctrl  n_dataset       n_bbk   is_strand_flip  is_diff_AF_gnomAD
#1       16226   AG      A       rs755466349     1.032e-02       -1.1136e-01     1.0118e-01      2.710e-01       5.531e-01       ???--???????    17511   302333  2       2       no      no
#1       48186   T       G       rs199900651     3.227e-03       -3.3715e-02     2.2063e-01      8.785e-01       2.904e-01       ????-?+?????    12444   248055  2       2       no      no

while(<F2>)
{chomp;
 if($.==1){print OUT "CPHS_ID\t$_\tlabel_comp_CPHS\n";}
 else
 {
 @hang=split;
 if($hang[0]<23)
 {
 $name1=$hang[0].":".$hang[1].":".$hang[2].":".$hang[3];  ### same
 $name2=$hang[0].":".$hang[1].":".$hang[3].":".$hang[2];  ### diff order
 $name3=$hang[0].":".$hang[1].":".flip($hang[2]).":".flip($hang[3]); ### flip (only for non-symmetric allele)
 $name4=$hang[0].":".$hang[1].":".flip($hang[3]).":".flip($hang[2]); ### flip and diff order (only for non-symmetric allele)
 }
 elsif($hang[0]==23)
 {$name1="X:".$hang[1].":".$hang[2].":".$hang[3];
  $name2="X:".$hang[1].":".$hang[3].":".$hang[2];
  $name3="X:".$hang[1].":".flip($hang[2]).":".flip($hang[3]);
  $name4="X:".$hang[1].":".flip($hang[3]).":".flip($hang[2]);
 }
 if(exists $our{$name1})
  {print OUT "$name1\t$_\tsame\n";}
 elsif(exists $our{$name2})
  {print OUT "$name2\t$_\tdiff_order\n";}
 elsif(exists $our{$name3})
  {$hang[2]=flip($hang[2]); $hang[3]=flip($hang[3]); print OUT "$name3\t"; print OUT join("\t",@hang); print OUT "\tflip\n";}
 elsif(exists $our{$name4})
  {$hang[2]=flip($hang[3]); $hang[3]=flip($hang[2]); $hang[6]=0-$hang[6]; print OUT "$name4\t"; print OUT join("\t",@hang); print OUT "\tflip_diff_order\n";}
 else
  {print OUT "$hang[4]\t$_\tnot_in_CPHS\n";}
 }
}
close F2;
close OUT;



