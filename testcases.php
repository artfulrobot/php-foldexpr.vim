<?php
use A as B;
use C;
use Dee;

/**
 * @file
 *
 * File docblock
 */

/**
 * Class to do X, Y, Z
 */
class FooPsr2
{
  /**
   * Some method
   */
  public function foo(Array $a)
  {
    // This is PSR-2 style
    return;
  }
}

/**
 * Class to do X, Y, Z
 */
class FooDrupal {
  /**
   * Some method
   */
  public function foo(Array $a) {
    // This is Drupal style
    return;
  }
}

/**
 * Some function
 */
function foo($a, $b=null) {
  $closure = function(
    $a, $b=null
    ) {
      return;
    };
  $b = $closure("foo");
}

/**
 * func with different layout
 */
function foo2($a, $b=null)
{
  $closure = function( $a, $b=null) {
      return;
    };
  $b = $closure("foo");
}

$a = Array(
  1,
  2,
  3,
  4,
);

$b = [
  1,
  2,
  3,
  4, ];

// Random curly block starts
{
    // Random curly block
    $a = 123;
}

if (FALSE) {
  // some if block
}
elseif (FALSE) {
  // some if else
}
else {
  // else
}

if (FALSE) {
  // some if block
} elseif (FALSE) {
  // some if else
} else {
  // else
}

if (FALSE)
{
  // some if block
}
elseif (FALSE)
{
  // some if else
}
else
{
  // else
}

try {
  $f = function() {
    throw new Exception("test");
  };
  $f();
}
catch (Exception $e) {
  print "foo";
}

function foo3(
  $arg1,
  $arg2
) {
   // do things!
}
$a = Array(
    1,
    2,
    3,
    4
  )
;
$a = Array(
  1,
  2,
  3,
  4,) ;

$a = Array(
  1,
  2,
  3,
  4
)
;


// Case a1
// WORKS: curlies=1, brackets=1
//
// FAILS: curlies=0, brackets=0
// FAILS: curlies=1, brackets=0
// FAILS: curlies=0, brackets=1
foobar(
   function ($arg) {
      // closure things!
   },
   'arg2'
);

$this_should_not_fold = [];


