#!/usr/bin/env perl
use warnings;
use strict;
use JSON;
my @temp=();
my $output=undef;

my %Roles_Subsystems=();
open(FH, "< ".$ENV{SEAVER_PROJECT}."PlantSEED_GitHub/DBs/PlantSEED_Roles.json");
my $data = undef;
while(<FH>){
    $data.=$_;
}
close(FH);

my @Roles = @{from_json($data)};
foreach my $row (@Roles){
    foreach my $ss (keys %{$row->{subsystems}}){
	$Roles_Subsystems{$row->{role}}{$ss}=1;
    }
}

use lib '/homes/seaver/Projects/PATRIC_Deploy/dev_container/modules/Workspace/lib/';
use Bio::P3::Workspace::ScriptHelpers;

my $Token_File = "/homes/seaver/Projects/PATRIC_Scripts/Workspace_Scripts/Login_Tokens.txt";
open(FH, "< $Token_File");
my %Tokens=();
while(<FH>){
    chomp;
    @temp=split(/\t/,$_,3);
    $Tokens{$temp[0]}=[$temp[1],$temp[2]];
}

#Set user for this
my $P3_User = 'seaver';
Bio::P3::Workspace::ScriptHelpers::login({ user_id => $P3_User, password => $Tokens{$P3_User}[0] });

my $Plants_Root = "/homes/seaver/Projects/PATRIC_Scripts/Workshops/2015/User_Genomes/";
my $User = $ARGV[0];
exit if !$User || !-d $Plants_Root.$User;

my $Name = $ARGV[1];
exit if !$Name;

#A Check for Genome object
my $User_Root = "/".$User."/plantseed/genomes";
my $Genome = Bio::P3::Workspace::ScriptHelpers::wscall("ls",{ paths => [$User_Root], adminmode=>1, excludeDirectories => 1 })->{$User_Root}[0][0];
#my $Minimal_Genome = ".".$Genome."/minimal_genome";

my $Genome_obj = Bio::P3::Workspace::ScriptHelpers::wscall("get",{ objects => [$User_Root."/".$Genome], adminmode => 1})->[0][1];
$Genome_obj = from_json($Genome_obj);

$Genome_obj->{taxonomy}=$Name;
print $Genome_obj->{taxonomy},"\n";
$data = to_json($Genome_obj);

Bio::P3::Workspace::ScriptHelpers::wscall("create",{ objects => [[$User_Root."/".$Genome,"genome",{},$data]], overwrite => 1, adminmode=>1 });
