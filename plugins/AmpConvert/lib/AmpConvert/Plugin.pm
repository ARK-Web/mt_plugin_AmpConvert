package AmpConvert::Plugin;
use strict;
use utf8;
use HTML::AmpConverter;

sub hdlr_block_amp_convert {
	my ($ctx, $args, $cond) = @_;

	my $builder = $ctx->stash('builder');
	my $tokens = $ctx->stash('tokens');
	defined (my $content = $builder->build($ctx, $tokens))
		or return $ctx->error($builder->errstr);

	my $app = MT->instance;
	my $base_url = defined $args->{"base_url"} ? $args->{"base_url"} : "";
	my $fix_img_size = defined $args->{"fix_img_size"} ? $args->{"fix_img_size"} : 1;
	my $responsive_width_threshold = defined $args->{"responsive_width_threshold"} ? int($args->{"responsive_width_threshold"}): undef;
	my $dont_remove_style = defined $args->{"dont_remove_style"} ? $args->{"dont_remove_style"} : undef;
	my $amp_converter = HTML::AmpConverter->new({
		base_url     => $base_url,
		fix_img_size => $fix_img_size,
		responsive_width_threshold => $responsive_width_threshold,
		dont_remove_style => $dont_remove_style,
	});
	$content = $amp_converter->convert($content);
	if (@{$amp_converter->{"errors"}}) {
		return $ctx->error(join("\n", @{$amp_converter->{"errors"}}));
	}
	if (@{$amp_converter->{"logs"}}) {
		$app->log({message => 'AmpConverter: ' . $ctx->stash('current_mapping_url'), metadata => join("\n", @{$amp_converter->{"logs"}})});
		@{$amp_converter->{"logs"}} = [];
	}

	return $content;
}

1;
