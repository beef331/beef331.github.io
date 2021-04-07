include karax / prelude
import std/[macros, strutils]
type 
  Post = object
    name, imgurl, linkurl, desc: string
  FooterEntry = object
    url, icon: string
  ShowcaseEntry = object
    name, url: string
  Pages = enum
    home, showcase


proc initPost(name, imgurl, linkurl, desc: string): Post =
  Post(name: name, imgurl: imgurl, linkurl: linkurl, desc: desc)

macro post(body: untyped): untyped =
  var posts: seq[Post]
  for child in body:
    if child.kind == nnkCall:
      let (name, iurl, lurl, desc) = block:
        var name, iurl, lurl, desc = ""
        for field in child[1]:
          case ($field[0]).nimIdentNormalize:
          of "name":
            name = $field[1][0]
          of "image":
            iurl = $field[1][0]
          of "link":
            lurl = $field[1][0]
          of "desc":
            desc = $field[1][0]
          else: discard
        (name, iurl, lurl, desc)
      posts.add initPost(name, iurl, lurl, desc)
  newLit(posts)


const Posts = post:
  child:
    name: "Pi Ui"
    image: "images/piui.png"
    link: "https://assetstore.unity.com/packages/tools/gui/pi-ui-94296"
    desc: """
PiUI is a radial menu creation tool for the Unity Engine.
It enables easy creation of screenspace radial menus.
Users can choose to make menus either dynamically, or manually in editor.
"""
  child:
    name: "Controller Manager"
    image: "images/Unity.png"
    link: "https://github.com/beef331/Unity-Controller-Manager"
    desc: """
Unity's out of the box controller support is(was) terrible.
Unity Controller Manager makes it easy to add 1-4 xInput controllers to any project.
After adding the inputs using either provided C# applications, simply use the new Controller namespace like Unity's Input namespace.
Quick and easy to use.
"""
  child:
    name: "Planetary Postage"
    image: "images/planetarypostage.png"
    link: "https://jbeetham.itch.io/planetarypostage?secret=WwAWkKQdVltyaNSSr1tbQwFi3M"
    desc: """
A 2D physics sandbox.
Launch projectiles from a Planet and watch its trajectory.
All planets are procedurally textured in shader.
"""
  child:
    name: "Pyroton Wine Manager"
    image: "images/pyrotonwinemanger.gif"
    link: "https://github.com/beef331/PyrotonWineManager"
    desc: """
A tool for modifying Steam proton's wine prefixes.
Enables users to quickly change wine settings, and navigate to specific prefixes.
"""
  child:
    name: "Hells Divide"
    image: "images/hells divide.gif"
    link: "https://jbeetham.itch.io/hells-divide"
    desc: """
Second place game jam game.
Unique roguelike first person slasher, that has players explore a dungeon, getting upgrades on level progression that change drastically.
"""
  child:
    name: "Point Renderer"
    image: "images/pointrenderer.png"
    link: "https://github.com/beef331/pointRenderer"
    desc: """
A simple rendering method that raycasts from the camera, and then renders quads that face the camera.
Quads then can have a custom texture applied to create interesting effects.
"""
  child:
    name: "Cords"
    image: "images/cords.gif"
    link: "https://jbeetham.itch.io/cords"
    desc: """
A 2 week long game jam game, with skill and puzzle solving.
Level editor and silly puzzles.
"""

const 
  footerEntries = [
    FooterEntry(
      url: "mailto://me@jasonbeetham.com",
      icon: "fas fa-envelope-open"
    ),
    FooterEntry(
      url: "https://github.com/beef331",
      icon: "fab fa-github"
    ),
    FooterEntry(
      url: "https://twitter.com/Beefers331",
      icon: "fab fa-twitter"
    )]
  showcaseEntries = [
    ShowcaseEntry(
      name: "SpaceRace",
      url: "videos/SpaceRace.mp4"
    ),
    ShowCaseEntry(
      name: "Point Renderer",
      url: "videos/pointrenderer.mp4"
    )
  ]
var currentPage = home

proc makeEntries(): VNode =
  result = buildHtml(ul):
    for post in Posts:
      li(class = "project"):
        a(href = post.linkurl, class = "post"):
          tdiv(class = "imageHolder"):
            img(src = post.imgurl)
          h2: text post.name
          p: text post.desc

proc makeHead(): VNode =
  result = buildHtml(head(class = "header")):
    link(rel = "stylesheet", type = "text/css", href = "main.css")
    link(
      rel = "stylesheet", type = "text/css",
      href = "https://use.fontawesome.com/releases/v5.7.2/css/all.css",
      integrity = "sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr",
      crossorigin = "anonymous"
      )
    link(rel = "icon", href = "Ico.png")
    title():
      text "Jason Beetham"

proc setToNothing(): VNode =
  buildHtml(tdiv):
    text "hello"

proc makeNavbar: VNode =
  template pageButton(kind: Pages, str: string): untyped  =
    buildHtml():
      if currentPage != kind:
          a(onclick = proc() = currentPage = kind):
            text str
      else:
        a(id = "pageOn"):
          text str

  buildHtml(header):
    tdiv(class = "navbar"):
      ul:
        li(class = "title"):
          text "Jason Beetham"
        li:
          text "Software Developer"
        li(class = "rightSide"):
          pageButton(showcase, "Showcase")

        li(class = "rightSide"):
          pageButton(home, "Projects")

proc makeFooter: Vnode =
  buildHtml:
    tdiv(class = "footer", id = "footer"):
      for entry in footerEntries:
        a(class = "fontAwesomeLink", href = entry.url):
          italic(class = entry.icon)

proc makeProjects: VNode = 
  buildhtml:
    tdiv(class = "page"):
      h1: 
        text "Projects"
      hr()
      ul:
        makeEntries()

proc makeShowcase(): VNode =
  buildHtml(tdiv(class = "page")):
    h1: 
      text "Showcase"
    hr()
    ul:
      for entry in showcaseEntries:
        li(class = "showcase"):
          h2 text entry.name
          video(src = entry.url, controls = "")
        hr()


proc makeDom(): VNode =
  buildhtml:
    section:
      makeHead()
      body:
        makeNavBar()
        video(class = "backVideo", autoplay = "", muted = "", loop = ""):
          source(src = "/videos/backvideo.mp4")
        tdiv(class = "wrapper"):
          case currentPage:
          of home:
            makeProjects()
          of showcase:
            makeShowcase()

      makeFooter()


setRenderer makeDom
