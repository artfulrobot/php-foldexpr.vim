<?php // vim: sw=4 ts=4 et
// Test fnPsr2
/**
 * A function
 */
function fnPsr2($a, $b=null)
{
    $closure = function( $a, $b=null) {
            return;
        };
    $b = $closure("foo");
}
// -----------------------------------------------------------------
// Test fnDrupal
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
// -----------------------------------------------------------------
// Test docblock
/**
 * @file
 *
 * File docblock
 */
// -----------------------------------------------------------------
// Test classPsr2
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
    /**
     * Some method
     */
    protected function fooProtected(Array $a)
    {
        // This is PSR-2 style
        return;
    }
    /**
     * Some method
     */
    private static function fooPrivate(Array $a)
    {
        // This is PSR-2 style
        return;
    }
}
// -----------------------------------------------------------------
// Test classDrupal
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
// -----------------------------------------------------------------


