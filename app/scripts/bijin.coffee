((i, s, o, g, r, a, m) ->
    i["GoogleAnalyticsObject"] = r
    i[r] = i[r] or ->
    (i[r].q = i[r].q or []).push arguments

    i[r].l = 1 * new Date()

    a = s.createElement(o)
    m = s.getElementsByTagName(o)[0]

    a.async = 1
    a.src = g
    m.parentNode.insertBefore a, m
) window, document, "script", "https://www.google-analytics.com/analytics.js", "ga"
ga "create", "UA-677679-28", "google.com"
ga "send", "pageview"


count = 0
itemWidth = 200
highQuality = true
bijin = {}
renderBijin = (bijinData) ->
    $photos = $("#photos")
    for bijin in bijinData
        hqThumbnail = "http://bjin.me/images/pic#{bijin.id}.jpg"
        lqThunbnail = bijin.thumb
        if highQuality
            thumbnail = hqThumbnail
        else
            thumbnail = lqThunbnail
        $photos.append "<li style=\"display: none;\"><a href=\"#{bijin.link}\" target=\"_blank\"><img data-id=\"#{bijin.id}\" data-category=\"#{bijin.category}\" data-pub-data=\"#{bijin.pubDate}\" data-hq-thumb=\"#{hqThumbnail}\" data-lq-thumb=\"#{lqThunbnail}\" src=\"#{thumbnail}\"></a></li>"

    $("#loading").fadeIn("fast")
    $photos.imagesLoaded ->
        $("#loading").hide()
        options =
            offset: 1
            autoResize: true
            itemWidth: itemWidth
            flexibleWidth: true
            container: $("#photos-container")
        $photos.find("li").wookmark(options).show()
    @

today = ->
    date = new Date()
    year = date.getFullYear()
    month = date.getMonth() + 1
    day = date.getDate()
    month = "0" + month if month < 10
    day = "0" + day if day < 10
    "#{year}/#{month}/#{day}"

$(".js-today").text today()

loadBijin = (count) ->
    if bijin.timestamp is today()
        renderBijin bijin.data
    else
        xhr = new XMLHttpRequest()
        requestUrl = "http://bjin.me/api/?format=json&count=#{count}&type=rand"
        xhr.open "GET", "http://jsonp.jit.su/?url=" + encodeURIComponent(requestUrl), true
        xhr.onreadystatechange = ->
            return unless xhr.readyState is 4
            bijinData = JSON.parse xhr.responseText
            renderBijin bijinData
            localStorage.setItem "bijin", JSON.stringify({data: bijinData, timestamp: today()})
        xhr.send()

$("#reload").click (e) ->
    e.preventDefault()
    localStorage.removeItem "bijin"
    $("#photos").find("li").remove()
    loadBijin count


count = parseInt(localStorage.getItem("count") || count)
itemWidth = parseInt(localStorage.getItem("itemWidth") || itemWidth)
highQuality = !!(localStorage.getItem("high-quality") || highQuality)
bijin = JSON.parse(localStorage.getItem("bijin") || "{}")

if count is 0
    widthNum = $(window).width() / itemWidth
    heightNum = ($(window).height() - 72) / itemWidth
    count = widthNum * heightNum
    count = 15 if count < 15

loadBijin count
