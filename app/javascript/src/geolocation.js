var suggestionArray = [];
var suggestionSelKey = "";
var currentRequest = null;

// Objekt obsahující zvolené územní celky
var selectedArray = [];

$(document).ready(function () {
    // Vyvolání funkce pro vyhledání po zadání hodnotu do vyhledávacího pole
    $("#volunteer_street_search").keyup(function () {
        $("#searchResult").empty();
        suggestionArray = [];

        var input = $(this).val();
        if (input.length > 3) {
            if (currentRequest !== null) {
                currentRequest.abort();
            }

            var obj = new Object();
            obj.Input = input;

            currentRequest = $.ajax({
                url: '/api/v1/geo/fulltext',
                type: "POST",
                dataType: "json",
                data: obj,
                success: function (data) {
                    suggestionSelKey = "";

                    if (data.length === 0) {
                        suggestionSelKey = "";
                    } else {
                        suggestionArray = [];

                        dropdownObject = [];

                        // Deduplikace podle více ID
                        const dedupedData = [];
                        for (const elem of data) {
                            if (
                              !dedupedData.some(
                                val =>
                                  val.okres_kod === elem.okres_kod &&
                                  val.obec_kod === elem.obec_kod &&
                                  val.cast_obce_kod === elem.cast_obce_kod
                              )
                            )
                              dedupedData.push(elem);
                          }

                        dedupedData.forEach(function (item, i) {
                            // Vytvoření objektu s adresním místem
                            var res = GetAddressFormat(item);

                            var locArr = [item.obec_nazev, item.cast_obce_nazev, item.ulice_nazev, item.cislo]
                            locArr = locArr.filter(function (v) {
                                return v !== null
                            });
                            var dropdownVal = locArr.join(', ');

                            suggestionArray.push({
                                value: res.placeholder, // Kompletní text zvoleného územního celku
                                ident: res.identificator, // Jedinečný identifikátor záznamu
                                type: res.type, // Typ územího celku
                                code: res.selected_identificator, // Identifikátor územího celku v ČÚZK službách,
                                dropdownVal: dropdownVal,
                                street: item.ulice_nazev,
                                streetNum: item.cislo,
                                city: item.obec_nazev,
                                cityPart: item.cast_obce_nazev
                            });

                            $("#searchResult").append('<li value="' + res.identificator + '"><span>' + dropdownVal + '</span></li>');

                            if (i === 0 && suggestionSelKey === "") {
                                suggestionSelKey = res.identificator;
                            }
                        });

                        $("#searchResult li").bind("click", function () {
                            onSelect(this);
                        });
                    }
                },
                error: function (e) {
                    console.log(e);
                    // Error
                }
            });
        } else if (input.length <= 3) {
            //
        }
    })
});

// Událost vyvolaná po zvolení požadované hodnoty
function onSelect(element) {
    var identSelection = $(element).attr('value');

    var result = suggestionArray.filter(function (obj) {
        return obj.ident === identSelection;
    })[0];

    // Funkce pro dotažení geometrie
    getGeometryByCode(result)

    $("#searchResult").empty();
    $("#volunteer_street_search").val(result.dropdownVal);

    $("#volunteer_street").val(result.street);
    $("#volunteer_street_number").val(result.streetNum);
    $("#volunteer_city").val(result.city);
    $("#volunteer_city_part").val(result.cityPart);
    $("#volunteer_geo_entry_id").val(result.ident);
    $("#volunteer_geo_unit_id").val(result.code);
}

function loadSelection() {
    $("#selectedResult").empty();

    selectedArray.forEach(function (item, i) {
        $("#selectedResult").append('<li value="' + item.ident + '">' + item.value + ' <span class="span-delete" onclick="removeSelection(' + i + ')">X</span></li>');
    });
}

function removeSelection(ident) {
    selectedArray.splice(ident, 1);

    loadSelection();
}

// Funkce pro dotažení geometrie k územnímu celku
function getGeometryByCode(item) {
    var reqURL = "https://ags.cuzk.cz/arcgis/rest/services/RUIAN/Vyhledavaci_sluzba_nad_daty_RUIAN/MapServer/" + item.type + "/query";

    if (currentRequest && currentRequest.readyState !== 4) {
        currentRequest.abort();
    }

    currentRequest = $.ajax({
        url: reqURL,
        async: false,
        cache: false,
        dataType: "jsonp",
        data: {
            where: 'kod=' + item.code,
            outFields: "kod",
            orderByFields: "kod",
            returnGeometry: true,
            returnTrueCurves: false,
            returnIdsOnly: false,
            returnCountOnly: false,
            resultRecordCount: 10,
            returnZ: false,
            returnM: false,
            returnExtentOnly: false,
            returnDistinctValues: false,
            geometryType: "esriGeometryEnvelope",
            spatialRel: "esriSpatialRelIntersects",
            featureEncoding: "esriDefault",
            f: 'pjson'
        },
        success: function (data) {
            if (data.features && data.features.length > 0) {
                var rawGeom = data.features[0].geometry;
                item.geom = JSON.stringify(rawGeom);

                $("#volunteer_geo_coord_x").val(rawGeom.x);
                $("#volunteer_geo_coord_y").val(rawGeom.y);

                selectedArray.push(item);
                loadSelection();
            }
        },
        error: function (e) {
            console.log('error ' + e);
        }
    });
}

// Vygenerování objektu s adresním místem
function GetAddressFormat(item) {
    var typeAddress = 0;
    var typeAddressText = '';
    var identAddress = 0;
    var fulltextStringFirst = [];
    var fulltextStringSecond = [];
    var fulltextStringPlaceholder = [];

    if (item.okres_kod !== null && item.okres_kod !== 0) {
        typeAddress = 15;
        typeAddressText = 'Okres';
        identAddress = item.okres_kod;
        fulltextStringFirst.push("<span style='font-size: 10px;'>okres " + item.okres_nazev + "</span>");
        fulltextStringPlaceholder.push("okres " + item.okres_nazev);
    }

    if (item.obec_kod !== null && item.obec_kod !== 0) {
        typeAddress = 12;
        typeAddressText = 'Obec';
        identAddress = item.obec_kod;
        fulltextStringFirst.push("<span style='font-size: 10px;'>obec " + item.obec_nazev + "</span>");
        fulltextStringPlaceholder.push("obec " + item.obec_nazev);
    }

    if (item.cast_obce_kod !== null && item.cast_obce_kod !== 0) {
        typeAddress = 11;
        typeAddressText = 'Část obce';
        identAddress = item.cast_obce_kod;
        fulltextStringSecond.push("<span style='font-size: 11px;'>část obce " + item.cast_obce_nazev + "</span>");
        fulltextStringPlaceholder.push("část obce " + item.cast_obce_nazev);
    }

    if (item.ulice_kod !== null && item.ulice_kod !== 0) {
        typeAddress = 4;
        typeAddressText = 'Ulice';
        identAddress = item.ulice_kod;
        fulltextStringSecond.push("<span style='font-size: 11px;'>ulice " + item.ulice_nazev + "</span>");
        fulltextStringPlaceholder.push('ulice ' + item.ulice_nazev);
    }

    if (item.adresa_kod !== null && item.adresa_kod !== 0) {
        typeAddress = 1;
        typeAddressText = 'Adresní místo';
        identAddress = item.adresa_kod;
        fulltextStringSecond.push("<span style='font-size: 11px;'>" + item.cislo + "</span>");
        fulltextStringPlaceholder.push(item.cislo);
    }

    var a = fulltextStringFirst.join(', ');
    var b = fulltextStringSecond.join(', ');
    fulltextStringPlaceholder = fulltextStringPlaceholder.join(', ');

    var fulltextString = a + "<br />" + b;

    var result = {
        type: typeAddress,
        identificator: generateAddressGuid(),
        fulltext: fulltextString,
        placeholder: fulltextStringPlaceholder,
        selected_identificator: identAddress,
        typeText: typeAddressText
    };

    return result;
}

function generateAddressGuid() {
    return Math.random().toString(36).substring(2, 15) +
        Math.random().toString(36).substring(2, 15);
}