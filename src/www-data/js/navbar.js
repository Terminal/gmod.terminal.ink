document.addEventListener('DOMContentLoaded', () => {
  const navside = document.getElementById('navside');
  const menuIcon = document.getElementById('menu-icon');
  const darken = document.getElementById('darken');

  menuIcon.addEventListener('click', () => {
    navside.style.transform = 'translateX(0)';
    darken.style.display = 'block';
    darken.style.pointerEvents = 'unset';
    setTimeout(() => {
      darken.style.opacity = '0.8';
    }, 1);
  });

  darken.addEventListener('click', () => {
    navside.style.transform = 'translateX(-250px)';
    darken.style.pointerEvents = 'none';
    darken.style.opacity = '0';
    setTimeout(() => {
      darken.style.display = 'none';
    }, 300);
  });
});
