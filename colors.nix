{ lib }:
let
    min = a: b: if a < b then a else b;
    max = a: b: if a > b then a else b;
    clamp = low: high: value: min high (max low value);
    abs = x: if x < 0 then -x else x;

    mixColors = color1: color2: amount:
        let
            a = lib.removePrefix "#" color1;
            b = lib.removePrefix "#" color2;

            channel = color: offset:
                lib.fromHexString (builtins.substring offset 2 color);

                mix = offset:
                    let
                        value = builtins.floor ( channel a offset * (1.0 - amount) + channel b offset * amount + 0.5 );
                    in
                        lib.fixedWidthString 2 "0" ( lib.toHexString value);
        in
            "#${mix 0}${mix 2}${mix 4}";

    saturateColor = color: amount:
        let 
            hex = lib.removePrefix "#" color;

            r = (lib.fromHexString ( builtins.substring 0 2 hex )) / 255.0;
            g = (lib.fromHexString ( builtins.substring 2 2 hex )) / 255.0;
            b = (lib.fromHexString ( builtins.substring 4 2 hex )) / 255.0;

            maxC = max r (max g b);
            minC = min r (min g b);
            delta = maxC - minC;

            lightness = (maxC + minC) / 2.0;
            saturation = if delta == 0 then 0.0 else delta / (1.0 - abs (2.0 * lightness - 1.0));
            hue = if delta == 0 then 0.0 
            else if maxC == r then 60.0 * (((g - b) / delta) + (if g < b then 6.0 else 0.0))
            else if maxC == g then 60.0 * (((b - r) / delta) + 2)
            else 60 * (((r - g) / delta) + 4.0);

            newSaturation = clamp 0.0 1.0 (saturation + amount);

            c = (1.0 - abs (2.0 * lightness - 1.0)) * newSaturation;

            hueSection = hue / 60.0;
            hueModulo = hueSection -2.0 * builtins.floor (hueSection / 2.0);
            x = c * (1.0 - abs (hueModulo - 1.0));
            m = lightness - c / 2.0;

            rgb = if hue < 60.0 then [ c x 0.0 ]
            else if hue < 120.0 then [ x c 0.0 ]
            else if hue < 180.0 then [ 0.0 c x ]
            else if hue < 240.0 then [ 0.0 x c ]
            else if hue < 300.0 then [ x 0.0 c ]
            else [ c 0.0 x ];

            toHex = v:
                lib.fixedWidthString 2 "0" (lib.toHexString (builtins.floor (clamp 0.0 255.0 ((v + m) * 255.0 + 0.5))));
        in
            "#${toHex (builtins.elemAt rgb 0)}${toHex (builtins.elemAt rgb 1)}${toHex (builtins.elemAt rgb 2)}";



    palettes = {
        peach = {
            primary = "#f38ba8";
            secondary = "#938bb4";
            tertiary = "#ff005d";
            accent = "#ff7c36";
            background = "#040405";
            dark = "#16161c";
            saturated = "#422549";
            dim = "#424242";
        };
    };
    
    active = "peach";
    colors = palettes.${active};

in 
{
    name = active;
    colors = colors // {
        pDark = mixColors colors.primary colors.background 0.25;
        pDarker = mixColors colors.primary colors.background 0.5;
        pVeryDark = mixColors colors.primary colors.background 0.75;
        pLight = mixColors colors.primary "#ffffff" 0.25;
        pLighter = mixColors colors.primary "#ffffff" 0.5;
        pVeryLight = mixColors colors.primary "#ffffff" 0.75;


        sPrimary = saturateColor colors.primary 0.5;
        sSecondary = saturateColor colors.secondary 0.5;
        sTertiary = saturateColor colors.tertiary 0.5;
    };
}
