#!/usr/bin/perl
# # # # # #
# Diversar funcoes para algum tipo
# de comunicacao com o browser do
# usuario.
# Tue Mar 20 12:34:00 BRT 2001
# # # # # #

package Ananke::Utils;
use strict;

our $VERSION = '1.0.1';

sub getCookies {
	# cookies are seperated by a semicolon and a space, this will split
   # them and return a hash of cookies
   my(@rawCookies) = split (/; /,$ENV{'HTTP_COOKIE'});
   my(%cookies);

   my($key,$val);
   foreach(@rawCookies){
   	($key, $val) = split (/=/,$_);
      $cookies{$key} = $val;
   }
        
   return %cookies;
}

# Trata os dados do form
# Formata timestamp.
# Sat Mar 17 22:31:06 BRT 2001
sub getTime {
   my($time) = @_;
   my ($seg,$min,$hora) = localtime($time);
   return sprintf("(%02d:%02d:%02d)",$hora,$min,$seg);
}

# Substitui chars proibidos
sub replace_chars {
   my($msg) = @_;
	$_ = $msg;

	s/�/&copy;/g; s/�/&otilde;/g; s/�/&reg;/g; s/�/&ouml;/g;
	s/�/&oslash;/g; s/"/&quot;/g; s/�/&ugrave;/g;
	s/�/&uacute;/g; s/</&lt;/g; s/�/&ucirc;/g;
	s/>/&gt;/g; s/�/&yacute;/g; s/�/&Agrave;/g; s/�/&thorn;/g;
	s/�/&Aacute;/g; s/�/&yuml;/g; s/�/&Acirc;/g; s/:/&#58;/g;
	s/�/&Atilde;/g; s/�/&Auml;/g; s/�/&Aring;/g; 
	s/�/&AElig;/g; s/�/&Ccedil;/g; s/�/&Egrave;/g; s/�/&Eacute;/g;
	s/�/&Ecirc;/g; s/�/&Euml;/g; s/�/&Igrave;/g; s/�/&Iacute;/g;
	s/�/&Icirc;/g; s/�/&Iuml;/g; s/�/&ETH;/g; s/�/&Ntilde;/g;
	s/�/&Otilde;/g; s/�/&Ouml;/g; s/�/&Oslash;/g; s/�/&Ugrave;/g;
	s/�/&Uacute;/g; s/�/&Ucirc;/g; s/�/&Uuml;/g; s/�/&Yacute;/g;
	s/�/&THORN;/g; s/�/&szlig;/g; s/�/&agrave;/g; s/�/&aacute;/g;
	s/�/&aring;/g; s/�/&aelig;/g; s/�/&ccedil;/g; s/�/&egrave;/g;
	s/�/&eacute;/g; s/�/&ecirc;/g; s/�/&euml;/g; s/�/&igrave;/g;
	s/�/&iacute;/g; s/�/&icirc;/g; s/�/&iuml;/g; s/�/&eth;/g;
	s/�/&ntilde;/g; s/�/&ograve;/g; s/�/&oacute;/g; s/�/&ocirc;/g;
	s/�/&atilde;/g;
	s/�/&pound;/g; s/�/&sect;/g; s/�/&laquo;/g; s/�/&yen;/g;
   s/�/&macr;/g; s/�/&raquo;/g; s/�/&times;/g; s/�/&eth;/g;
   s/�/&cent;/g; s/�/&curren;/g; s/�/&brvbar;/g; s/�/&not;/g;
   s/�/&ordm;/g; s/�/&frac12;/g; s/�/&frac14;/g; s/�/&frac34;/g;
   s/�/&ordf;/g; s/�/&acute;/g; s/�/&para;/g; s/�/&middot;/g;
   s/�/&cedil;/g; s/�/&sup1;/g; s/�/&divide;/g; s/�/&sup3;/g;
   s/�/&iquest;/g; s/�/&ETH;/g; s/�/&uml;/g; s/�/&iexcl;/g;
   s/�/&plusmn;/g; 

	s/!/&#33/g; s/@/&#64/g; s/\$/&#36/g; s/%/&#37/g;
	s/\*/&#42/g; s/\(/&#40/g; s/\)/&#41/g;
	s/\//&#47/g; s/\\/&#92/g;
	
   return $_;

}

# Recupega Post com multiples values
sub getForm {
   my($r,$rr) = @_;
   my($i,@j,$k,%r);

   # Printa conteudo
   if ($r) { $r = $r; }
   elsif ($rr) { $r = $rr; }
   else { return; }

   $i = $r;

   while ($i =~ s/^([a-zA-Z0-9-_\%\.\,\+]+)=([a-zA-Z0-9-_\*\@\%\.\,\+]+)?&?//sx) {
      $j[0] = $1;
      $j[1] = $2;

      # Trasnforma os chars especiais em normais
      $j[0] =~ tr/+/ /;
      $j[0] =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $j[1] =~ tr/+/ /;
      $j[1] =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

      # Verifica quantas vezes se repete     
      $k = $r =~ s/(^|&)($j[0]=)/$1$2/gi;

      # Verifica se joga em array ou hash
      if ($k > 1) { push (@{$r{$j[0]}},$j[1]); }
      else { $r{$j[0]} = $j[1] }

      $k = 0;
   }

   return %r if %r;
   return 0;
}

# see /usr/src/usr.bin/passwd/local_passwd.c or librcypt, crypt(3)
sub salt {
    my($salt);               # initialization
    my($i, $rand);
    my(@itoa64) = ( '0' .. '9', 'a' .. 'z', 'A' .. 'Z' ); # 0 .. 63

    # to64
    for ($i = 0; $i < 27; $i++) {
        srand(time + $rand + $$);
        $rand = rand(25*29*17 + $rand);
        $salt .=  $itoa64[$rand & $#itoa64];
    }

    return $salt;
}

# Esconda a string
sub escape {
   my ($str,$pat) = @_;
   $pat = '^A-Za-z0-9 ' if ( $pat eq '' );
   $str =~ s/([$pat])/sprintf("%%%02lx", unpack("c",$1))/ge;
   $str =~ s/ /\+/g;
   return $str;
}     

# Decoda a string
sub unescape { 
   my ($str) = @_;
   $str =~ s/\+/ /g;
   $str =~ s/%(..)/pack("c", hex($1))/ge;
   return $str;
}

# substitui enters por html
sub clean {
   my($str) = @_;

   $str =~ s/\\r//g;
   $str =~ s/\\n\\n/<p>/g;
   $str =~ s/\\n/<br>/g;

   return $str;
}

1;

=head1 NAME

Ananke::Utils - Utility functions

=head1 DESCRIPTION

Utility functions used to facility your life

=head1 SYNOPSIS

	See all functions

=head1 METHODS

=head2 getCookies()
  
	Retrieves any cookie information from the browser

	%cookies = Ananke::Utils::getCookies;

=head2 getTime(timestamp)

	Return time in hh:mm:ss

	$var = &Ananke::Utils::getTime(time());

=head2 replace_chars(string)

	Replace all bad chars to html format

	$var = &Ananke::Utils::escape("��TesTЪ");

=head2 getForm(x,x)

	If you use modperl, this functions is very good

	my $r = shift;
	my (%form,$i,$j);
	$i=$r->content; $j=$r->args;
	%form = &Ananke::Utils::getForm($i,$j);

	this function understand array input, id[1], id[2],id[3]...

=head2 salt()

	Return randomic string, used for generate password

=head2 escape(string)

	URL encode

	http://web/this has spaces' -> 'http://web/this%20has%20spaces'

	$var = &Ananke::Utils::escape($ENV{'REQUEST_URI'});

=head2 unescape(string)

	URL decode

	http://web/this%20has%20spaces -> http://web/this has spaces'

	$var = &Ananke::Utils::escape("http://web/this%20has%20spaces");

=head2 clean(string)

	Convert enter to <br> and 2 enters to <p>

	$var = clean($textarea);

=head1 AUTHOR

	Udlei D. R. Nattis
	nattis@anankeit.com.br
	http://www.nobol.com.br
	http://www.anankeit.com.br

=cut
