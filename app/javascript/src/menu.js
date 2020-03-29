$(document).ready(function () {
    const menuButton = document.querySelector('#js-menu-button');
    const closeMenuButton = document.querySelector('#js-close-menu-button');
    const mobileLinks = document.querySelectorAll('#js-mobile-menu-list .slide-link');
    const desktopLinks = document.querySelectorAll('#js-desktop-menu-list .slide-link');
    const mobileMenu = document.querySelector('#js-mobile-menu-container');
    const body = document.querySelector('body');
    const wannaJoinButton = document.querySelector('#js-mobile-menu-container .main-button');

    const closeCallback = () => {
        mobileMenu.classList.remove('open');
        body.style.height = '';
        body.style.overflow = '';
    };

    const scrollToId = id => document.querySelector('#' + id).scrollIntoView();
    const smoothlyScrollToId = id => document.querySelector('#' + id).scrollIntoView({behavior: 'smooth'});

    menuButton.onclick = () => {
        mobileMenu.classList.add('open');
        body.style.height = '100vh';
        body.style.overflow = 'hidden';
    };

    const linkIds = ['intro', 'guide', 'counts', 'organizace'];

    mobileLinks.forEach((link, index) => link.addEventListener('click', () => {
        closeCallback();
        if (linkIds[index]) {
            scrollToId(linkIds[index]);
        }
    }));

    desktopLinks.forEach((link, index) => link.addEventListener('click', () => {
        if (linkIds[index]) {
            smoothlyScrollToId(linkIds[index]);
        }
    }));

    closeMenuButton.onclick = closeCallback;

    wannaJoinButton.addEventListener('click', closeCallback);
});