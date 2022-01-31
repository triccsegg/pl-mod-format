use strict;
use LWP::UserAgent;
use utf8;

my $input_file      = 'in.txt';
my $output_file     = 'out.txt';
my $log_file        = 'log.txt';


my $article_anchor  = "\x{25BC}";  #▼
my $tmp_file_prefix = 'tmp';
my $input_file_phase;
my $output_file_phase;
###### main ######
open LOGF, >":encoding(UTF-8)","$log_file"  or die "can't open file $log_file" ;

print LOGF "###### step 01: clean format ######\n";
$input_file_phase  = "$input_file";
$output_file_phase = "01_${tmp_file_prefix}_clean_format.txt";
&clean_format;

print LOGF "###### step 02: clean new line ######\n";
$input_file_phase  = "01_${tmp_file_prefix}_clean_format.txt";
$output_file_phase = "02_${tmp_file_prefix}_clean_new_line.txt";
&clean_new_line;

print LOGF "###### step 03: clean bold format ######\n";
$input_file_phase  = "02_${tmp_file_prefix}_clean_new_line.txt";
$output_file_phase = "03_${tmp_file_prefix}_clean_bold.txt";
&clean_bold;

print LOGF "###### step 04: add new line to picture ######\n";
$input_file_phase  = "03_${tmp_file_prefix}_clean_bold.txt";
$output_file_phase = "04_${tmp_file_prefix}_pic_add_new_line.txt";
&pic_add_new_line;

print LOGF "###### step 05: add new line to arrow ######\n";
$input_file_phase  = "04_${tmp_file_prefix}_pic_add_new_line.txt";
$output_file_phase = "05_${tmp_file_prefix}_arrow_add_new_line.txt";
&arrow_add_new_line;

print LOGF "###### step 06: modify picture format ######\n";
$input_file_phase  = "05_${tmp_file_prefix}_arrow_add_new_line.txt";
$output_file_phase = "06_${tmp_file_prefix}_pic_format.txt";
&mod_pic_format;

print LOGF "###### step 07: modify picture size ######\n";
$input_file_phase  = "06_${tmp_file_prefix}_pic_format.txt";
$output_file_phase = "07_${tmp_file_prefix}_pic_size.txt";
&mod_pic_size;

print LOGF "###### step 08: add <br /> ######\n";
$input_file_phase  = "07_${tmp_file_prefix}_pic_size.txt";
$output_file_phase = "$output_file";
&add_format;

close(LOGF);

##################
sub clean_format
{
open INF , "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;
  while (<INF>)
  {	  
    chomp;

    s!\s*<p>\s*!!g; #discard <p>
	s!\s*</p>\s*!\n!g; #</p> => \n
    s!\s*<div.*?>\s*!!g; #discard <div ...>
	s!\s*</div>\s*!\n!g; #</div> => \n
	
	s!\s*<br />\s*<br />\s*!<br />\n<br />!g; #<br /><br /> => <br />\n<br />
	
	print OUTF "$_\n";
  }
  
close(OUTF);
close(INF);
}

sub clean_new_line
{
open INF , "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;
  while (<INF>)
  {	  
    chomp;
	
	s!\s*<br />\s*!!g; #discard <br /> 
	
	print OUTF "$_\n";
  }
  
close(OUTF);
close(INF);
}

sub clean_bold
{
  my $old_var = $/;
  $/=undef;
  open INF , "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
  my $all_line = <INF>;
  close(INF);
  $/=$old_var;  
  
  open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;
  $all_line =~ s!<b>\n(.*?)</b>!<b>$1</b>!g;
  print OUTF $all_line;
  close(OUTF);

}

sub pic_add_new_line
{
open INF , "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;
  while (<INF>)
  {	  
    chomp;
	
	if(m!^(.+?)(<a\s*href\s*=\s*"https://blogger.googleusercontent.com/img/.*)!)
	{
	  #print OUTF "line:$_\n";
      my $head_match;
	  my $tail_match;
	  
	  while(m!^(.+?)(<a\s*href\s*=\s*"https://blogger.googleusercontent.com/img/.*)!) #ensure <a href ... is first character
	  {
	    $head_match = $1;
	    $tail_match = $2;
	  
        $head_match =~ s!(<a\s*href\s*=\s*"https://blogger.googleusercontent.com/img/.*?</a>)(\s*)(\S+)!$1\n$3!g; #<a href...</a>XXX => <a href...</a>\nXXX
	    print OUTF "$head_match\n";
	    $_ = $tail_match;
	  }
	    
	  if($tail_match =~ m!(<a\s*href\s*=\s*"https://blogger.googleusercontent.com/img/.*?</a>)(\s*)(\S+)!) #<a href...</a>XXX => <a href...</a>\nXXX
	  {
        print OUTF "$1\n$3\n";
	  }
	  else
	  {
        print OUTF "$_\n";
	  }
	}
	else
	{
	  print OUTF "$_\n";
	}
  }
  
close(OUTF);
close(INF);
}

sub arrow_add_new_line
{
open INF , "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;
  while (<INF>)
  {	  
    chomp;

    if(m!^(.+?)($article_anchor.*)!)
	{
	  my $head_match;
	  my $tail_match;	
	  
	  while(m!^(.+?)($article_anchor.*)!) #XXX▼    => XXX\n▼
	  {
	    $head_match = $1;
	    $tail_match = $2;		  
	    print OUTF "$head_match\n";
	    $_ = $tail_match;
	  }		
      print OUTF "$tail_match\n"; #the last ▼
	}
	else
	{
	  print OUTF "$_\n";
	}
  }
  
close(OUTF);
close(INF);
}

sub mod_pic_format
{
open INF,  "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;

  while (<INF>)
  {
    chomp;
	if($_ !~ /<a\s*href.*?=s\d+\s*"/)
	{
		s!(<a\s*href\s*=\s*"https://blogger.googleusercontent.com/img/.*?)".*?>.*?(<img.*?)\s*"\s*/>\s*</a>!$1=s16000">$2=s16000"/></a>!g;
	}
    print OUTF "$_\n";
  }
  
close(OUTF);
close(INF);
}

sub mod_pic_size
{
open INF,  "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;

  while (<INF>)
  {
    chomp;
	
	#s!height="640"!!g;
	#s!width="640"!!g;
	(my $mod_str = $_) =~ s,=s\d+",=s16000",g; #keep orignal size at $_
	if($_ =~ m,=s\d+", and $_ !~ m,=s16000",)
	{
	  print LOGF "=== change the size to s16000 ===\n";
	  print LOGF "org:$_\n";
	  print LOGF "mod:$mod_str\n";
	}
    
	print OUTF "$mod_str\n";
  }
  
close(OUTF);
close(INF);
}

sub add_format
{
open INF,  "<:encoding(UTF-8)", "$input_file_phase"   or die "can't open file $input_file_phase" ;
open OUTF, ">:encoding(UTF-8)", "$output_file_phase"  or die "can't open file $output_file_phase" ;

  while (<INF>)
  {
    chomp;
	s!^(&nbsp;)+!!g; #delete inital space	
	s!^( )+!!g; #delete inital space
	print OUTF "$_<br />\n";
  }
  
close(OUTF);
close(INF);
}