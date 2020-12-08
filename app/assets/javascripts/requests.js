function update_volunteer_counts() {
  console.log('update_volunteer_counts')
  let path = window.location.pathname.split('/')
  let requestId = path[path.length - 1]

  $.ajax({ url: `/admin/organisation_requests/${requestId}/requested_volunteers/count` }).done(function(data) {
    $('#ui-id-1').text(`Potvrzení (${data.accepted})`)
    $('#ui-id-2').text(`K oslovení (${data.to_be_notified})`)
    $('#ui-id-3').text(`Ostatní (${data.others})`)
  })
}