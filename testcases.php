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
