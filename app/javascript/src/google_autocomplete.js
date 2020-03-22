$(document).ready(
    window.signUpLocationCallback = function (){
        //var input = $("#volunteer_street_search")
        var input = document.getElementById('volunteer_street_search');
        var options = {
            types: ['establishment']
        };

        var autocomplete = new google.maps.places.Autocomplete(input, options);
        autocomplete.addListener("place_changed", function() {
            var place = autocomplete.getPlace()
            var lat   = place.geometry.location.lat()
            var lng   = place.geometry.location.lng()

            // fill values properly
            $("#volunteer_street_search").val(result.dropdownVal);

            $("#volunteer_street").val(result.street);
            $("#volunteer_street_number").val(result.streetNum);
            $("#volunteer_city").val(result.city);
            $("#volunteer_city_part").val(result.cityPart);
            $("#volunteer_geo_entry_id").val(result.ident);
            $("#volunteer_geo_unit_id").val(result.code);
            $("#volunteer_geo_coord_x").val(place.geometry.location.lng());
            $("#volunteer_geo_coord_y").val(place.geometry.location.lat());
        })


});
