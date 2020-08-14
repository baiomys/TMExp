unit Unit2;

interface

uses sysutils;

type TLangRec = record
        Name    : string;
        LongID  : string;
        code    : integer;
        ext     : string;
      end;

const

cLangs : array [0..161] of TLangRec = (
(Name : 'Undefined';                    LongId : '';      code : 0;    ext : ''    ),
(Name : 'Afrikaans';                    LongId : 'af';    code : 1078; ext : 'AFK' ),
(Name : 'Korean';                       LongId : 'ko';    code : 1042; ext : 'KOR' ),
(Name : 'Japanese';                     LongId : 'ja';    code : 1041; ext : 'JAP' ),
(Name : 'Italian-Italy';                LongId : 'it-it'; code : 1040; ext : 'ITA' ),
(Name : 'Italian-Switzerland';          LongId : 'it-ch'; code : 2064; ext : 'ITS' ),
(Name : 'Russian';                      LongId : 'ru';    code : 1049; ext : 'RUS' ),
(Name : 'Russian-Moldova';              LongId : 'ru-mo'; code : 2073; ext : 'RUM' ),
(Name : 'Greek';                        LongId : 'el';    code : 1032; ext : 'ELL' ),
(Name : 'Swedish-Finland';              LongId : 'sv-fi'; code : 2077 ),
(Name : 'Swedish-Sweden';               LongId : 'sv-se'; code : 1053; ext : 'SVE' ),
(Name : 'Portuguese-Brazil';            LongId : 'pt-br'; code : 1046; ext : 'PTB' ),
(Name : 'Portuguese-Portugal';          LongId : 'pt-pt'; code : 2070; ext : 'PTG' ),
(Name : 'Norwegian-Bokml';              LongId : 'no-no'; code : 1044; ext : 'NOR' ),
(Name : 'Norwegian-Nynorsk';            LongId : 'no-no'; code : 2068; ext : 'NON' ),
(Name : 'English-Australia';            LongId : 'en-au'; code : 3081; ext : 'ENA' ),
(Name : 'English-Belize';               LongId : 'en-bz'; code : 10249),
(Name : 'English-Canada';               LongId : 'en-ca'; code : 4105; ext : 'ENC' ),
(Name : 'English-Caribbean';            LongId : 'en-cb'; code : 9225 ),
(Name : 'English-Great Britain';        LongId : 'en-gb'; code : 2057; ext : 'ENG' ),
(Name : 'English-India';                LongId : 'en-in'; code : 16393),
(Name : 'English-Ireland';              LongId : 'en-ie'; code : 6153; ext : 'ENI' ),
(Name : 'English-Jamaica';              LongId : 'en-jm'; code : 8201 ),
(Name : 'English-New Zealand';          LongId : 'en-nz'; code : 5129; ext : 'ENZ'),
(Name : 'English-Phillippines';         LongId : 'en-ph'; code : 13321),
(Name : 'English-Southern Africa';      LongId : 'en-za'; code : 7177 ),
(Name : 'English-Trinidad';             LongId : 'en-tt'; code : 11273),
(Name : 'English-United States';        LongId : 'en-us'; code : 1033; ext : 'ENU' ),
(Name : 'German-Austria';               LongId : 'de-at'; code : 3079; ext : 'DEA' ),
(Name : 'German-Germany';               LongId : 'de-de'; code : 1031; ext : 'DEU' ),
(Name : 'German-Liechtenstein';         LongId : 'de-li'; code : 5127; ext : 'DEC' ),
(Name : 'German-Luxembourg';            LongId : 'de-lu'; code : 4103; ext : 'DEC' ),
(Name : 'German-Switzerland';           LongId : 'de-ch'; code : 2055; ext : 'DES' ),
(Name : 'Spanish-Argentina';            LongId : 'es-ar'; code : 11274),
(Name : 'Spanish-Bolivia';              LongId : 'es-bo'; code : 16394),
(Name : 'Spanish-Chile';                LongId : 'es-cl'; code : 13322),
(Name : 'Spanish-Colombia';             LongId : 'es-co'; code : 9226 ),
(Name : 'Spanish-Costa Rica';           LongId : 'es-cr'; code : 5130 ),
(Name : 'Spanish-Dominican Republic';   LongId : 'es-do'; code : 7178 ),
(Name : 'Spanish-Ecuador';              LongId : 'es-ec'; code : 12298),
(Name : 'Spanish-El Salvador';          LongId : 'es-sv'; code : 17418),
(Name : 'Spanish-Guatemala';            LongId : 'es-gt'; code : 4106 ),
(Name : 'Spanish-Honduras';             LongId : 'es-hn'; code : 18442),
(Name : 'Spanish-Mexico';               LongId : 'es-mx'; code : 2058; ext : 'ESM' ),
(Name : 'Spanish-Nicaragua';            LongId : 'es-ni'; code : 19466),
(Name : 'Spanish-Panama';               LongId : 'es-pa'; code : 6154 ),
(Name : 'Spanish-Paraguay';             LongId : 'es-py'; code : 15370),
(Name : 'Spanish-Peru';                 LongId : 'es-pe'; code : 10250),
(Name : 'Spanish-Puerto Rico';          LongId : 'es-pr'; code : 20490),
(Name : 'Spanish-Spain';                LongId : 'es-es'; code : 1034; ext : 'ESP' ),
(Name : 'Spanish-Uruguay';              LongId : 'es-uy'; code : 14346),
(Name : 'Spanish-Venezuela';            LongId : 'es-ve'; code : 8202 ),
(Name : 'Finnish';                      LongId : 'fi';    code : 1035; ext : 'FIN' ),
(Name : 'French-Belgium';               LongId : 'fr-be'; code : 2060; ext : 'FRB' ),
(Name : 'French-Canada';                LongId : 'fr-ca'; code : 3084; ext : 'FRC' ),
(Name : 'French-France';                LongId : 'fr-fr'; code : 1036; ext : 'FRA' ),
(Name : 'French-Luxembourg';            LongId : 'fr-lu'; code : 5132; ext : 'FRL' ),
(Name : 'French-Switzerland';           LongId : 'fr-ch'; code : 4108; ext : 'FRS' ),
(Name : 'Turkish';                      LongId : 'tr';    code : 1055 ),
(Name : 'Polish';                       LongId : 'pl';    code : 1045; ext : 'PLK' ),
(Name : 'Hungarian';                    LongId : 'hu';    code : 1038; ext : 'HUN' ),
(Name : 'Danish';                       LongId : 'da';    code : 1030 ),
(Name : 'Dutch-Belgium';                LongId : 'nl-be'; code : 2067; ext : 'NLB' ),
(Name : 'Dutch-Netherlands';            LongId : 'nl-nl'; code : 1043; ext : 'NLD' ),
(Name : 'Chinese-China';                LongId : 'zh-cn'; code : 2052 ),
(Name : 'Chinese-Hong Kong SAR';        LongId : 'zh-hk'; code : 3076 ),
(Name : 'Chinese-Macau SAR';            LongId : 'zh-mo'; code : 5124 ),
(Name : 'Chinese-Singapore';            LongId : 'zh-sg'; code : 4100 ),
(Name : 'Chinese-Taiwan';               LongId : 'zh-tw'; code : 1028 ),
(Name : 'Thai';                         LongId : 'th';    code : 1054 ),
(Name : 'Catalan';                      LongId : 'ca';    code : 1027; ext : 'CAT' ),
(Name : 'Czech';                        LongId : 'cs';    code : 1029; ext : 'CSY' ),
(Name : 'Albanian';                     LongId : 'sq';    code : 1052 ),
(Name : 'Amharic';                      LongId : 'am';    code : 1118 ),
(Name : 'Arabic-Algeria';               LongId : 'ar-dz'; code : 5121 ),
(Name : 'Arabic-Bahrain';               LongId : 'ar-bh'; code : 15361),
(Name : 'Arabic-Egypt';                 LongId : 'ar-eg'; code : 3073 ),
(Name : 'Arabic-Iraq';                  LongId : 'ar-iq'; code : 2049 ),
(Name : 'Arabic-Jordan';                LongId : 'ar-jo'; code : 11265),
(Name : 'Arabic-Kuwait';                LongId : 'ar-kw'; code : 13313),
(Name : 'Arabic-Lebanon';               LongId : 'ar-lb'; code : 12289),
(Name : 'Arabic-Libya';                 LongId : 'ar-ly'; code : 4097 ),
(Name : 'Arabic-Morocco';               LongId : 'ar-ma'; code : 6145 ),
(Name : 'Arabic-Oman';                  LongId : 'ar-om'; code : 8193 ),
(Name : 'Arabic-Qatar';                 LongId : 'ar-qa'; code : 16385),
(Name : 'Arabic-Saudi Arabia';          LongId : 'ar-sa'; code : 1025 ),
(Name : 'Arabic-Syria';                 LongId : 'ar-sy'; code : 10241),
(Name : 'Arabic-Tunisia';               LongId : 'ar-tn'; code : 7169 ),
(Name : 'Arabic-United Arab Emirates';  LongId : 'ar-ae'; code : 14337),
(Name : 'Arabic-Yemen';                 LongId : 'ar-ye'; code : 9217 ),
(Name : 'Armenian';                     LongId : 'hy';    code : 1067 ),
(Name : 'Assamese';                     LongId : 'as';    code : 1101 ),
(Name : 'Azeri-Cyrillic';               LongId : 'az-az'; code : 2092 ),
(Name : 'Azeri-Latin';                  LongId : 'az-az'; code : 1068 ),
(Name : 'Basque';                       LongId : 'eu';    code : 1069 ),
(Name : 'Belarusian';                   LongId : 'be';    code : 1059 ),
(Name : 'Bengali-Bangladesh';           LongId : 'bn';    code : 2117 ),
(Name : 'Bengali-India';                LongId : 'bn';    code : 1093 ),
(Name : 'Bosnian';                      LongId : 'bs';    code : 5146 ),
(Name : 'Bulgarian';                    LongId : 'bg';    code : 1026 ),
(Name : 'Burmese';                      LongId : 'my';    code : 1109 ),
(Name : 'Estonian';                     LongId : 'et';    code : 1061 ),
(Name : 'FYRO Macedonia';               LongId : 'mk';    code : 1071 ),
(Name : 'Faroese';                      LongId : 'fo';    code : 1080 ),
(Name : 'Farsi-Persian';                LongId : 'fa';    code : 1065 ),
(Name : 'Gaelic-Ireland';               LongId : 'gd-ie'; code : 2108 ),
(Name : 'Gaelic-Scotland';              LongId : 'gd';    code : 1084 ),
(Name : 'Guarani-Paraguay';             LongId : 'gn';    code : 1140 ),
(Name : 'Gujarati';                     LongId : 'gu';    code : 1095 ),
(Name : 'Hebrew';                       LongId : 'he';    code : 1037 ),
(Name : 'Hindi';                        LongId : 'hi';    code : 1081 ),
(Name : 'Icelandic';                    LongId : 'is';    code : 1039 ),
(Name : 'Indonesian';                   LongId : 'id';    code : 1057 ),
(Name : 'Kannada';                      LongId : 'kn';    code : 1099 ),
(Name : 'Kashmiri';                     LongId : 'ks';    code : 1120 ),
(Name : 'Kazakh';                       LongId : 'kk';    code : 1087 ),
(Name : 'Khmer ';                       LongId : 'km';    code : 1107 ),
(Name : 'Lao';                          LongId : 'lo';    code : 1108 ),
(Name : 'Latin';                        LongId : 'la';    code : 1142 ),
(Name : 'Latvian';                      LongId : 'lv';    code : 1062 ),
(Name : 'Lithuanian';                   LongId : 'lt';    code : 1063 ),
(Name : 'Malay-Brunei';                 LongId : 'ms-bn'; code : 2110 ),
(Name : 'Malay-Malaysia';               LongId : 'ms-my'; code : 1086 ),
(Name : 'Malayalam';                    LongId : 'ml';    code : 1100 ),
(Name : 'Maltese';                      LongId : 'mt';    code : 1082 ),
(Name : 'Maori';                        LongId : 'mi';    code : 1153 ),
(Name : 'Marathi';                      LongId : 'mr';    code : 1102 ),
(Name : 'Mongolian';                    LongId : 'mn';    code : 2128 ),
(Name : 'Mongolian';                    LongId : 'mn';    code : 1104 ),
(Name : 'Nepali';                       LongId : 'ne';    code : 1121 ),
(Name : 'Oriya';                        LongId : 'or';    code : 1096 ),
(Name : 'Punjabi';                      LongId : 'pa';    code : 1094 ),
(Name : 'Raeto-Romance';                LongId : 'rm';    code : 1047 ),
(Name : 'Romanian-Moldova';             LongId : 'ro-mo'; code : 2072 ),
(Name : 'Romanian-Romania';             LongId : 'ro';    code : 1048 ),
(Name : 'Sanskrit';                     LongId : 'sa';    code : 1103 ),
(Name : 'Serbian-Cyrillic';             LongId : 'sr-sp'; code : 3098 ),
(Name : 'Serbian-Latin';                LongId : 'sr-sp'; code : 2074 ),
(Name : 'Setsuana';                     LongId : 'tn';    code : 1074 ),
(Name : 'Sindhi';                       LongId : 'sd';    code : 1113 ),
(Name : 'Sinhala	Sinhalese';           LongId : 'si';    code : 1115 ),
(Name : 'Slovak';                       LongId : 'sk';    code : 1051 ),
(Name : 'Slovenian';                    LongId : 'sl';    code : 1060 ),
(Name : 'Somali';                       LongId : 'so';    code : 1143 ),
(Name : 'Sorbian';                      LongId : 'sb';    code : 1070 ),
(Name : 'Swahili';                      LongId : 'sw';    code : 1089 ),
(Name : 'Tajik';                        LongId : 'tg';    code : 1064 ),
(Name : 'Tamil';                        LongId : 'ta';    code : 1097 ),
(Name : 'Tatar';                        LongId : 'tt';    code : 1092 ),
(Name : 'Telugu';                       LongId : 'te';    code : 1098 ),
(Name : 'Tibetan';                      LongId : 'bo';    code : 1105 ),
(Name : 'Tsonga';                       LongId : 'ts';    code : 1073 ),
(Name : 'Turkmen';                      LongId : 'tk';    code : 1090 ),
(Name : 'Ukrainian';                    LongId : 'uk';    code : 1058 ),
(Name : 'Urdu';                         LongId : 'ur';    code : 1056 ),
(Name : 'Uzbek-Cyrillic';               LongId : 'uz-uz'; code : 2115 ),
(Name : 'Uzbek-Latin';                  LongId : 'uz-uz'; code : 1091 ),
(Name : 'Vietnamese';                   LongId : 'vi';    code : 1066 ),
(Name : 'Welsh';                        LongId : 'cy';    code : 1106 ),
(Name : 'Xhosa';                        LongId : 'xh';    code : 1076 ),
(Name : 'Yiddish';                      LongId : 'yi';    code : 1085 ),
(Name : 'Zulu';                         LongId : 'zu';    code : 1077 ));

function GetCode(code : integer) : integer;
function HTMLDecode(const AStr: wideString): widestring;

implementation

function GetCode(code : integer) : integer;
begin
  for result := 1 to length(cLangs) do
    if cLangs[result].code=code then exit;
  result:=0;
end;

// ------------------------
function HTMLDecode(const AStr: wideString): widestring;
var
  Sp, Rp, Cp, Tp: PChar;
  S: String;
  I, Code: Integer;
begin
  SetLength(Result, Length(AStr));
  Sp := PChar(AStr);
  Rp := PChar(Result);
  Cp := Sp;
  try
    while Sp^ <> #0 do  begin
      case Sp^ of
        '&': begin
               Cp := Sp; Inc(Sp);
               case Sp^ of
                 'a': begin
                        if AnsiStrPos(Sp, 'amp;') = Sp then begin
                          Inc(Sp, 3);  Rp^ := '&';
                        end else if AnsiStrPos(Sp, 'apos;') = Sp then begin
                          Inc(Sp, 4);  Rp^ := '''';
                        end;
                      end;

                 'l': begin
                        if AnsiStrPos(Sp, 'lt;') = Sp then begin
                          Inc(Sp, 2);  Rp^ := '<';
                        end;
                      end;

                 'g': begin
                        if AnsiStrPos(Sp, 'gt;') = Sp then begin
                          Inc(Sp, 2);  Rp^ := '>';
                        end;
                      end;

                 'n': if AnsiStrPos(Sp, 'nbsp;') = Sp then begin
                        Inc(Sp, 4);    Rp^ := ' ';
                      end;

                 'q': if AnsiStrPos(Sp, 'quot;') = Sp then begin
                        Inc(Sp,4);     Rp^ := '"';
                      end;
                 'S': if AnsiStrPos(Sp, 'SP;') = Sp then begin
                        Inc(Sp,2);     Rp^ := ' ';
                      end;
                 else
                   Exit;
               end;
           end
      else Rp^ := Sp^;
      end;
      Inc(Rp); Inc(Sp);
    end;
  except
  end;
  SetLength(Result, Rp - PChar(Result));
end;


end.
