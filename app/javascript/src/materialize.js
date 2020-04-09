function send_modal_view(modal) {
    if(typeof(ga) != "undefined") {
        ga('send', 'pageview', {
            'page': '/modal/' + String(modal.id)
        });
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const elems = document.querySelectorAll('.modal');
    const instances = M.Modal.init(elems, {
        onOpenEnd: send_modal_view
    });

    const registrationViaWeb = document.querySelector('#register-via-web');
    registrationViaWeb.addEventListener('click', () => {
        const modalElement = document.querySelector('#registration');
        const modalInstance = M.Modal.getInstance(modalElement);
        modalInstance.close();
    });
});

document.addEventListener('DOMContentLoaded', function() {
    const elems = document.querySelectorAll('.tooltipped');
    const instances = M.Tooltip.init(elems, {});
});
