function findProperty(input, type, property) {
    try {
        return input.find(function(i) { return i.types[0] === type })[property] || ""
    } catch (e) {
        return ''
    }
}

function handleAutocompleteKeypress(event, target) {
  if (event.target.value.length === 0) {
    target.val("")
  }
}

function handleAutocompleteBlur(event, target) {
  if (event.target.value.length === 0) {
    target.val("")
  }
}

window.initAutocompleteForResultElements = function(result_prefix){
    console.log(result_prefix)
    var input = $(".geocomplete")
    var target = $("#" + input.data("target"))
    var autocomplete = new google.maps.places.Autocomplete(input[0])
    autocomplete.setTypes([])
    autocomplete.setComponentRestrictions({country: "cz"})
    input[0].addEventListener('keypress', function keypressHandler(event) { handleAutocompleteKeypress(event, target) }, { passive: true })
    input[0].addEventListener('blur', function blurHandler(event) { handleAutocompleteBlur(event, target) }, { passive: true })

    autocomplete.addListener("place_changed", function() {
        var place = autocomplete.getPlace()
        var lat   = place.geometry.location.lat()
        var lng   = place.geometry.location.lng()
        var address = {}
        if (place.address_components) {
            const components = place.address_components
            address = {
                country_code: findProperty(components, "country", "short_name").toLowerCase(),
                postal_code: findProperty(components, "postal_code", "long_name"),
                city: findProperty(components, "locality", "long_name") || findProperty(components, "administrative_area_level_2", "long_name"),
                city_part: findProperty(components, "neighborhood", "long_name"),
                street: findProperty(components, "route", "long_name"),
                street_number: findProperty(components, "street_number", "long_name"),
                lat: lat,
                lng: lng,
                remote_provider_id: place.place_id || ""
            }
        }
        $('#' + result_prefix +'_country_code').val(address.country_code)
        $('#' + result_prefix +'_postal_code').val(address.postal_code)
        $('#' + result_prefix +'_city').val(address.city)
        $('#' + result_prefix +'_city_part').val(address.city_part || address.city)
        $('#' + result_prefix +'_street').val(address.street)
        $('#' + result_prefix +'_street_number').val(address.street_number)
        $('#' + result_prefix +'_latitude').val(address.lat)
        $('#' + result_prefix +'_longitude').val(address.lng)
        $('#' + result_prefix +'_geo_entry_id').val(address.remote_provider_id)
    })
}

function InitAddressAutocomplete() {
    $(document).ready(function() {
        initAutocompleteForResultElements('address')
    })
}

function InitRequestAutocomplete() {
    $(document).ready(function() {
        initAutocompleteForResultElements('request_address_attributes')
    })
}

function InitFilterAutocomplete() {
    $(document).ready(function() {
        var input = $(".geocomplete_filter")
        var target = $("#" + input.data("target"))
        var autocomplete = new google.maps.places.Autocomplete(input[0])
        autocomplete.setTypes([])
        autocomplete.setComponentRestrictions({country: "cz"})
        input[0].addEventListener('keypress', function keypressHandler(event) { handleAutocompleteKeypress(event, target) }, { passive: true })
        input[0].addEventListener('blur', function blurHandler(event) { handleAutocompleteBlur(event, target) }, { passive: true })

        autocomplete.addListener("place_changed", function() {
            var place = autocomplete.getPlace()
            var lat   = place.geometry.location.lat()
            var lng   = place.geometry.location.lng()

            $('#q_search_nearby').val(lat + '#' + lng)
        })
    })
}