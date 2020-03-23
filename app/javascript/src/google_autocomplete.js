window.findProperty = function (input, type, property) {
    try {
        return input.find(function(i) { return i.types[0] === type })[property] || ""
    } catch (e) {
        return ''
    }
}
window.signUpLocationCallback = function (){
    //var input = $("#volunteer_street_search")
    var input = $('#volunteer_street_search');
    var autocomplete = new google.maps.places.Autocomplete(input[0]);
    autocomplete.setTypes(['address']);
    autocomplete.setComponentRestrictions({country: "cz"});
    input.prop('placeholder', '')

    autocomplete.addListener("place_changed", function() {
        // TODO: extract into common module with ActiveAdmins geocomplete file
        var place = autocomplete.getPlace();
        var lat   = place.geometry.location.lat();
        var lng   = place.geometry.location.lng();
        var address = {};
        if (place.address_components) {
            const components = place.address_components;
            address = {
                country_code: findProperty(components, "country", "short_name").toLowerCase(),
                postal_code: findProperty(components, "postal_code", "long_name"),
                city: findProperty(components, "locality", "long_name") || findProperty(components, "administrative_area_level_2", "long_name"),
                city_part: findProperty(components, "neighborhood", "long_name"),
                street: findProperty(components, "route", "long_name"),
                street_number: findProperty(components, "street_number", "long_name"),
                lat: lat,
                lng: lng,
                remote_provider_id: place.place_id
            }
        }
        $('#volunteer_country_code').val(address.country_code);
        $('#volunteer_postal_code').val(address.postal_code);
        $('#volunteer_city').val(address.city);
        $('#volunteer_city_part').val(address.city_part || address.city);
        $('#volunteer_street').val(address.street);
        $('#volunteer_street_number').val(address.street_number);
        $('#volunteer_geo_coord_y').val(address.lat);
        $('#volunteer_geo_coord_x').val(address.lng);
        $('#volunteer_geo_entry_id').val(address.remote_provider_id);
        $('#volunteer_geo_unit_id').val(address.remote_provider_id);
    })
}
