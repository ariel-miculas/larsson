#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use Data::Dumper;

my $vowel = qr/[aeiouâăîøå]/;
my $letter = qr/[a-zA-Zâăîțșøå]/;
my $ro_uppercase = qr/[A-ZȘȚÎ]/;

sub read_input
{
	my $text = join '', <>;
	return $text;
}
sub usage
{
	"$0 filename";
}

sub double_random_letter
{
	my $word = shift;
	my @doubled_consonants = qw(m n p r s t);
	my @doubled_vowels = qw(a o e);

	my $r = int(rand(@doubled_consonants));
	if ($word !~ s/(?<!^)($doubled_consonants[$r])(?=$vowel)/$1$1/)
	{
		$r = int(rand(@doubled_vowels));
		$word =~ s/(?<!^)($doubled_vowels[$r])(?!$)/$1$1/;
	}
	return $word;
}

sub double_letter
{
	my $word = shift;
	my @doubled_consonants = qw(m n t r s);
	my @doubled_vowels = qw(e a ø);

	if (is_preposition($word))
	{
		return $word;
	}

	if (int(rand(2)))
	{
		for my $l (@doubled_consonants)
		{
			if ($word =~ s/(?<!^)(?<!$l)($l)(?=$vowel)/$1$1/)
			{
				last;
			}
		}
	}
	else
	{

		for my $l (@doubled_vowels)
		{
			if ($word =~ s/(?<!^)(?<!$l)($l)(?=$letter)/$1$1/)
			{
				last;
			}
		}
		$word =~ s/øø/øo/g;
	}
	return $word;
}

sub process_word
{
	my $word = shift;
	my $is_capitalized;
	$is_capitalized = ($word =~ s/^($ro_uppercase)/lc($1)/e);

	$word =~ s/-//g;
	$word =~ s/j?ea/ja/g;
	$word =~ s/za/se/g;
	$word =~ s/z/s/g;
	$word =~ s/ți(?!$letter)/ts/g;
	$word =~ s/ți/tzi/g;
	$word =~ s/ț/ts/g;
	$word =~ s/oa?/ø/g;
	$word =~ s/v(?!$letter)/f/;
	$word =~ s/v/w/g;
	$word =~ s/chi/kj/;
	$word =~ s/c(?![ie])/k/g;
	$word =~ s/ci(?!$letter)/ch/;
	$word =~ s/ș/sch/g;
	$word =~ s/î/y/g;
	$word =~ s/(?<=$vowel)i(?!$letter)/j/g;
	$word =~ s/^i(?=$vowel)/y/g;
	$word =~ s/(?<!^)((?<!$vowel)i(?!$vowel))/y/g;
	$word =~ s/(?<!^)i/ij/g;
	$word =~ s/â/y/g;
	$word =~ s/ă/å/g;

	$word = double_letter($word);
	if ($is_capitalized)
	{
		$word =~ s/^(.)/uc($1)/e;
	}

	return $word;
}

sub is_preposition
{
	my $word = shift;
	return length($word) <= 3;

}

sub process_line
{
	my $line = shift;
	my @original_words = split ' ', $line;
	my @words;
	my $compound_word = "";
	my $nr_words = 0;

	for my $word (@original_words)
	{
		$word =~ /((?:$letter++|-)++)/;
		my $word_wo_punctuation = $1;

		if ($word !~ /^[A-Z]/)
		{
			$word =~ s/^da\b/ja/;
			$word =~ s/^eu\b/jø/;
			$word =~ s/^e\b/je/;
		}

		my $new_word;
		if (substr($compound_word, -1, 1) eq substr($word, 0, 1))
		{
			$new_word = $compound_word.substr($word, 1);
		}
		else
		{
			$new_word = $compound_word.$word;
		}

		if (!is_preposition($word)
		   || $word =~ /^$ro_uppercase{2,}/
		   || $word =~ /[;,.]/
		   || $nr_words > 2)
		{
			if ($nr_words <= 1 && $word !~ /^$ro_uppercase{2,}/)
			{
				push @words, $new_word;
			}
			else
			{
				push @words, $compound_word if $compound_word;
				push @words, $word;
			}
			$compound_word = "";
			$nr_words = 0;
		}
		else
		{
			$compound_word .= $word;
			$nr_words++;
		}
	}
	push @words, $compound_word if $compound_word;

	for my $word (@words)
	{
		next if $word =~ /^$ro_uppercase{2,}/;
		$word = process_word($word);
	}
	return join " ", @words;
}

my $data = read_input();
my @output = split "\n", $data;

my @result = map {process_line($_)} @output;
print join ("\n", @result), "\n";

