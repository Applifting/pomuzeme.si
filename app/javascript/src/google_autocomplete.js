window.findProperty = function (input, type, property) {
    try {
        return input.find(function(i) { return i.types[0] === type })[property] || ""
    } catch (e) {
        return ''
    }
}

function initPlacesSearch(element) {
    var resource_type = element.getAttribute('data-type');
    var autocomplete = new google.maps.places.Autocomplete(element);
    autocomplete.setTypes([]);
    autocomplete.setComponentRestrictions({country: "cz"});
    element.placeholder = ""

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
        $(`#${resource_type}_country_code`).val(address.country_code);
        $(`#${resource_type}_postal_code`).val(address.postal_code);
        $(`#${resource_type}_city`).val(address.city);
        $(`#${resource_type}_city_part`).val(address.city_part || address.city);
        $(`#${resource_type}_street`).val(address.street);
        $(`#${resource_type}_street_number`).val(address.street_number);
        $(`#${resource_type}_geo_coord_y`).val(address.lat);
        $(`#${resource_type}_geo_coord_x`).val(address.lng);
        $(`#${resource_type}_geo_entry_id`).val(address.remote_provider_id);
        $(`#${resource_type}_geo_unit_id`).val(address.remote_provider_id);
    })
}
window.signUpLocationCallback = function (){
    var inputs = document.getElementsByClassName('location_search');

    for (let item of inputs) {
        initPlacesSearch(item);
    }
}


$(document).on('turbolinks:load', function() {
    window.signUpLocationCallback();
});