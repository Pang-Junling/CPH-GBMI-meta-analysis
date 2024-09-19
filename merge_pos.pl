#!usr/bin/perl
use strict;
my(@hang,%mr);
open F1,"<$ARGV[0]";  ### snp.bim
while(<F1>)
{chomp;
 @hang=split;
 $mr{$hang[1]}=join("\t", $hang[1], $hang[0], $hang[3]);
}
close F1;

open OUT, ">>$ARGV[2]"; ### meta results with SNP pos
open F2,"<$ARGV[1]"; ### meta results
while(<F2>)
{chomp;
 @hang=split;
 if(exists $mr{$hang[0]})
  {print OUT "$mr{$hang[0]}\t"; print OUT join("\t",@hang); print OUT "\n";}
}
close F2;
close OUT;
