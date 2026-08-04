use strict;
use warnings;

use Test::More;

use lib 'lib';
use Source qw(
  classify_source
  normalize_issue_url
  same_origin_issue_url
  validate_issue_url
);

is(
  normalize_issue_url('https://example.com/issues/42', 'https://example.com/archive/'),
  'https://example.com/issues/42',
  'keeps an absolute HTTPS issue URL intact',
);

is(
  normalize_issue_url('/issues/42', 'https://example.com/archive/'),
  'https://example.com/issues/42',
  'resolves a relative issue URL against its source page',
);

ok(!validate_issue_url('javascript:alert(1)'), 'rejects executable URL schemes');
ok(!validate_issue_url('http://example.com/issue'), 'rejects unencrypted issue URLs');
ok(
  !same_origin_issue_url('https://169.254.169.254/latest/meta-data/', 'https://example.com/archive/'),
  'rejects cross-origin follow-up URLs',
);

is(
  classify_source({ updated_at => time() - 10 * 24 * 60 * 60, cadence_days => 7 }, time()),
  'current',
  'keeps a source within its cadence grace period current',
);

is(
  classify_source({ updated_at => time() - 31 * 24 * 60 * 60, cadence_days => 7 }, time()),
  'stale',
  'quarantines a source older than three cadence periods',
);

is(
  classify_source({ updated_at => time(), updated_fixed_day => 'Thursday' }, time()),
  'low_confidence',
  'does not present estimated fixed-weekday dates as fresh',
);

is(classify_source({}, time()), 'failed', 'records scrape failures explicitly');

done_testing();
