let base = document.getElementsByClassName("project")[0];
let data = {
    "posts": [
        {
            "name": "Pi Ui",
            "imgurl": "piui.png",
            "href": "https://assetstore.unity.com/packages/tools/gui/pi-ui-94296",
            "desc": "PiUI is a radial menu creation tool for the Unity Engine. It enables easy creation of screenspace radial menus. Users can choose to make menus either dynamically, or manually in editor."

        },
        {
            "name": "Controller Manager",
            "imgurl": "Unity.png",
            "href": "https://github.com/beef331/Unity-Controller-Manager",
            "desc": "Unity's out of the box controller support is terrible. Unity Controller Manager makes it easy to add 1-4 xInput controllers to any project. After adding the inputs using either provided C# applications, simply use the new Controller namespace like Unity's Input namespace. Quick and easy to use."
        },
        {
            "name": "Planetary Postage",
            "imgurl": "planetarypostage.png",
            "href": "https://jbeetham.itch.io/planetarypostage?secret=WwAWkKQdVltyaNSSr1tbQwFi3M",
            "desc": "A 2D physics sandbox. Launch projectiles from a Planet and watch its trajectory. All planets are procedurally textured in shader"
        },
        {
            "name": "Pyroton Wine Manager",
            "imgurl": "pyrotonwinemanger.gif",
            "href": "https://github.com/beef331/PyrotonWineManager",
            "desc": "A tool for modifying Steam proton's wine prefixes. Enables users to quickly change wine settings, and navigate to specific prefixes."
        },
        {
            "name": "Hells Divide",
            "imgurl": "https://img.itch.zone/aW1nLzIzMjI1MTAuZ2lm/original/xR%2FMHp.gif",
            "href": "https://jbeetham.itch.io/hells-divide",
            "desc": "Second place game jam game. Unique roguelike first person slasher, that has players explore a dungeon, getting upgrades on level progression that change dirastically."
        },
    ]
};
for (let i = 0; i < data['posts'].length; i++) {
    let post = data['posts'][i];
    let newElement = base.cloneNode(true);
    let href = newElement.getElementsByTagName('a')[0];
    let title = newElement.getElementsByTagName('h2')[0];
    let desc = newElement.getElementsByTagName('p')[0];
    let imgurl = newElement.getElementsByTagName('img')[0];
    title.innerText = post['name'];
    href.href = post['href'];
    desc.innerText = post['desc'];
    imgurl.src = post['imgurl'];
    base.parentElement.appendChild(newElement);
    base.parentElement.appendChild(document.createElement('hr'));
}
base.parentElement.removeChild(base);