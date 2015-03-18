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

// The following case works with curlies on or off, but only when brackets is off.
function foo3(
  $arg1,
  $arg2
) {
   // do things!
}
// The following do not work

$a = Array(
  1,
  2,
  3,
  4, );

$this_should_not_fold = [];



