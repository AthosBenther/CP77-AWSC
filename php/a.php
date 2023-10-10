<?php
$range = [
    'MeleeWeapon',
    'RangedWeapon'
];


$class = [
    'BladeWeapon',
    'BluntWeapon',
    'HeavyWeapon',
    'PowerWeapon',
    'SmartWeapon',
    'TechWeapon',
    'ThrowableWeapon',
    'OneHandedRangedWeapon',
    'Special'
];

$kind = [
    'Grenade Launcher',
    'Handgun',
    'HMG',
    'LMG',
    'Revolver',
    'Rifle Assault',
    'Rifle Precision',
    'Rifle Sniper',
    'ShotgunWeapon',
    'Shotgun Dual',
    'SMG',

    'Baton',
    'BladeWeapon',
    'One Hand Blade',
    'One Hand Club',
    'Katana',
    'Knife',
    'Two Hand Club',
    'Two Hand Hammer',
    'Knuckles'

];

$weapons = json_decode(file_get_contents('fnames.json'), true);

ksort($weapons);

$weapons2 = [];


foreach ($weapons as $weapon => $props) {
    if (!$weapon || $weapon == 'None') continue;
    $stats = $props['stats'];
    ksort($stats);
    $tags = $props['tags'];

    $path = '';

    $thisRange = arrK(array_values(array_intersect($range, $tags)), 0);
    $thisClass = arrK(array_values(array_intersect($class, $tags)), 0);
    $thisKind = arrK(array_values(array_intersect($kind, $tags)), 0);
    $isIconic = in_array('IconicWeapon', $tags);

    if (!$thisRange || !$thisClass || !$thisKind) {
        print_r([$weapon => [
            'Range' => $thisRange,
            'Class' => $thisClass,
            'Kind' => $thisKind,
            'Iconic' => $isIconic ? 'true' : 'false',
            'Tags' => $tags
        ]]);
    } else if ($thisRange != 'MeleeWeapon' && $thisClass != 'OneHandedRangedWeapon') {
        $weapons2[$thisRange][$thisClass][$thisKind] = [$weapon => [
            'Stats' => $stats,
            'Tags' => $tags
            ]];
    }
}

file_put_contents('fnames2.json', json_encode($weapons2,JSON_PRETTY_PRINT));

function arrK($array, $key)
{
    if (is_array($array)) {
        return $array[$key] ?? null;
    } else return null;
}
