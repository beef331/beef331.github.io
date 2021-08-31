include karax / prelude
from dom import window, Location, document, decodeURI
import std/[macros, strutils]
type
  Post = object
    name, imgurl, linkurl, desc: string
  FooterEntry = object
    url, icon: string
  ShowcaseEntry = object
    name, url: string
  Pages = enum
    home = "#Projects", showcase = "#Showcase"


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
    name: "Linerino"
    image: "images/linerino.png"
    link: "https://jbeetham.itch.io/linerino"
    desc: """
A fun simple yet challenging puzzle game made in Nim utilizing the Nico framework.
Play handcrafted levels, or procedural generated endless levels.
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
    name: "Planetary Postage"
    image: "images/planetarypostage.png"
    link: "https://jbeetham.itch.io/planetarypostage?secret=WwAWkKQdVltyaNSSr1tbQwFi3M"
    desc: """
A 2D physics sandbox.
Launch projectiles from a Planet and watch its trajectory.
All planets are procedurally textured in shader.
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
    ]
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
        a(class = "post", href = post.linkurl):
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
    link(rel = "icon", href = "images/Ico.png")
    title():
      text "Jason Beetham"

proc makeNavbar: VNode =
  proc pageButton(kind: Pages, str: string): VNode =
    buildHtml():
      if currentPage != kind:
        a(onclick = proc() =
          currentPage = kind
          window.location.href = $kind):
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

proc parseUrl() =
  try:
    let
      loc = ($window.location.href)
      kind = parseEnum[Pages](loc[loc.rfind('/') + 1 .. ^1])
    currentPage = kind
  except: discard
proc makeDom(): VNode =
  document.title = "Jason Beetham"
  parseUrl()
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
