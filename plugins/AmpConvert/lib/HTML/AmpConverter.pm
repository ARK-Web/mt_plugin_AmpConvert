package HTML::AmpConverter;
use strict;
use utf8;

sub new {
	my ($class, $opts) = @_;

	my $self = {};
	$self->{"errors"} = [];
	$self->{"logs"} = [];
	$self->{"end_tags"} = [];
	$self->{"base_url"} = $opts->{"base_url"} || '';
	$self->{"fix_img_size"} = $opts->{"fix_img_size"} || '';
	$self->{"responsive_width_threshold"} = $opts->{"responsive_width_threshold"};

	my @modules = (
		'HTML::TokeParser', 
	);
	if ($self->{"fix_img_size"}) {
		push @modules, 'LWP::UserAgent';
		push @modules, 'Image::Size';
	}
	foreach my $module (@modules) {
		eval "require $module";
		if ($@) {
			push @{$self->{"errors"}}, "Perl module $module is required to HTML::AmpConverter\n$@";
			$self->{$module} = 0;
		} else {
			$self->{$module} = 1;
		}
	}

	return bless $self, $class;
}

sub convert {
	my ($self, $html) = @_;

	return $html unless $self->{'HTML::TokeParser'};

	my $content = "";
	my $p = HTML::TokeParser->new(\$html);
	while (my $token = $p->get_token) {
		my $type = $token->[0];
		if ($type eq "S") {		# Start tag
			my $tagname   = $token->[1];
			my %attrs     = %{$token->[2]};
			my @attr_keys = @{$token->[3]};
			my $text      = $token->[4];

			my $changed = $self->convert_to_amp(\$tagname, \%attrs, \$text);
			if ($changed) {
				my $end = $attrs{'/'} ? ' /' : '';
				delete $attrs{'/'} if $attrs{'/'};
				my $attr_string = "";
				foreach my $key (keys %attrs) {
					$attr_string .= sprintf(' %s="%s"', $key, $attrs{$key});
				}
				$content .= sprintf('<%s%s%s>', $tagname, $attr_string, $end);
			}
			else {
				$content .= $text;
			}
		}
		elsif ($type eq "E") {	# End tag
			my $tagname = $token->[1];
			my $text    = $token->[2];

			$self->convert_to_amp_end_tag(\$tagname, \$text);

			$content .= $text;
		}
		elsif ($type eq "T" || $type eq "C" || $type eq "D") {	# Other tags
			my $text = $token->[1];

			$content .= $text;
		}
		elsif ($type eq "PI") {	# <?php
			my $text = $token->[2];

			$content .= $text;
		}
	}
	return $content;
}

sub convert_to_amp {
	my ($self, $tagname, $attr) = @_;

	my $changed = 0;

	# delete style attr
	if ($attr->{"style"}) {
		delete $attr->{"style"};
		$changed = 1;
	}
	# convert img tag to amp-img
	if ($$tagname eq 'img') {
		$changed |= $self->convert_to_amp_img($tagname, $attr);
	}
	# convert youtube iframe to amp-youtube
	elsif ($$tagname eq 'iframe') {
		$changed |= $self->convert_to_amp_youtube($tagname, $attr);
	}
	return $changed;
}

sub convert_to_amp_img {
	my ($self, $tagname, $attr) = @_;

	my $changed = 1;
	$$tagname = 'amp-img';
	if (!$attr->{"width"} || !$attr->{"height"}) {
		if ($attr->{"src"} && $self->{"fix_img_size"} && $self->{"LWP::UserAgent"} && $self->{"Image::Size"}) {
			my $url = $attr->{"src"};
			if ($url !~ m/^https?:\/\//) {
				$url = $self->{"base_url"} . $attr->{"src"};
			}
			my $size_info = $self->fix_img_width_height($url);
			if ($size_info) {
				$attr->{"width"}  = $size_info->{"width"};
				$attr->{"height"} = $size_info->{"height"};
			}
		}
	}
	if (defined $self->{"responsive_width_threshold"} && $attr->{"width"}) {
		if ($attr->{"width"} >= $self->{"responsive_width_threshold"}) {
			$attr->{"layout"} = "responsive";
		}
	}
	return $changed;
}

sub convert_to_amp_youtube {
	my ($self, $tagname, $attr) = @_;

	my $changed = 0;
	if (defined $attr->{"src"} && $attr->{"src"} =~ m/^https?:\/\/www\.youtube\.com\/embed\/(.*)$/) {
		my $videoid = $1;
		$$tagname = 'amp-youtube';
		$attr->{"data-videoid"} = $videoid;
		$attr->{"layout"} = "responsive";
		delete $attr->{src};
		delete $attr->{frameborder};
		delete $attr->{allowfullscreen};

		unshift @{$self->{'end_tags'}}, {'tag' => 'iframe', 'new_tag' => 'amp-youtube'};
		$changed = 1;
	} else {
		unshift @{$self->{'end_tags'}}, {'tag' => 'iframe', 'new_tag' => 'iframe'};
	}
	return $changed;
}

sub convert_to_amp_end_tag {
	my ($self, $tagname, $text) = @_;

	if (@{$self->{'end_tags'}} > 0) {
		my $end_tag = $self->{'end_tags'}->[0];
		if ($$tagname eq $end_tag->{tag}) {
			$$tagname = $end_tag->{new_tag};
			$$text = sprintf("</%s>", $$tagname);
			shift @{$self->{'end_tags'}};
		}
	}
}

sub fix_img_width_height {
	my ($self, $url) = @_;

	$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

	my $ua = LWP::UserAgent->new;
	my $response = $ua->get($url);
	if ($response->is_success) {
		my $img = $response->content;
		my ($width, $height, $id) = Image::Size::imgsize(\$img);
		if ($width && $height) {
			return {width => $width, height => $height};
		} else {
			push @{$self->{"logs"}}, "Failed to Image::Size::imgsize $url. $id";
		}
	} else {
		push @{$self->{"logs"}}, "Failed to LWP::UserAgent::get $url. " . $response->status_line;
	}
	return undef;
}

1;
