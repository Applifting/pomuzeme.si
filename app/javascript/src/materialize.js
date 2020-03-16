function send_modal_view(modal) {
    if(typeof(ga) != "undefined") {
        ga('send', 'pageview', {
            'page': '/modal/' + String(modal.id)
        });
    }
}

document.addEventListener('DOMContentLoaded', function() {
    var elems = document.querySelectorAll('.modal');
    var instances = M.Modal.init(elems, {
        onOpenEnd: send_modal_view
    });
});

document.addEventListener('DOMContentLoaded', function() {
    var elems = document.querySelectorAll('.tooltipped');
    var instances = M.Tooltip.init(elems, {});
});
