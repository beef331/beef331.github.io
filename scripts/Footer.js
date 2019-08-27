let domEle = document.getElementById("footer");
let faKeys = Object.keys(faLinks);
for (let i = 0; i < faKeys.length; i++) {
    let clickableIcon = document.createElement('a');
    let icon = document.createElement('i');
    clickableIcon.className = 'fontAwesomeLink';
    clickableIcon.href = faLinks[faKeys[i]];
    icon.className = faKeys[i];
    clickableIcon.appendChild(icon);
    domEle.appendChild(clickableIcon);
}