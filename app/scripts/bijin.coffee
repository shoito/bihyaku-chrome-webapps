count = 0
itemWidth = 200
highQuality = true
bijin = {}
controlVisibleClass = "show"

$photos = $(".js-photos")
$loading = $(".js-loading")
$ctrlCol = $(".js-control-collapse > i")

relocatePhotos = ->
    options =
        offset: 1
        autoResize: true
        itemWidth: itemWidth
        flexibleWidth: true
        container: $(".js-photos-container")
    $photos.find("li").wookmark(options).show()

toggleControl = (controlVisible)->
    controlVisibleClass = if controlVisible then "show" else ""
    $photoCtrl = $(".js-controls")
    if controlVisible
        $ctrlCol.removeClass("icon-collapse").addClass "icon-collapse-top"
        $photoCtrl.show()
    else
        $ctrlCol.removeClass("icon-collapse-top").addClass "icon-collapse"
        $photoCtrl.hide()

renderBijin = (bijinData) ->
    for bijin in bijinData
        hqThumbnail = "http://bjin.me/images/pic#{bijin.id}.jpg"
        lqThunbnail = bijin.thumb
        thumbnail = if highQuality then hqThumbnail else lqThunbnail
        $photos.append """
        <li class="photo-container" style="display: none;">
            <a href="#{bijin.link}" target="_blank" class="control bjinme" title="Bjin.Meで詳細を見る">
                <i class="icon-heart"></i>
            </a>
            <a href="#" class="js-photo" title="#{bijin.category}の写真をもっと見る" >
                <img data-id="#{bijin.id}" data-category="#{bijin.category}" 
                    data-pub-data="#{bijin.pubDate}" data-hq-thumb="#{hqThumbnail}" 
                    data-lq-thumb="#{lqThunbnail}" src="#{thumbnail}">
            </a>
            <div class="js-controls controls #{controlVisibleClass}">
                <a href="https://www.google.co.jp/search?q=#{bijin.category}&safe=off&tbm=isch" target="_blank" class="control" title="Google画像検索で#{bijin.category}を探す">
                    <i class="btn-google"></i>
                </a>
                <a href="http://www.youtube.com/results?search_query=#{bijin.category}" target="_blank" class="control" title="YouTubeで#{bijin.category}を探す">
                    <i class="icon-youtube-play"></i>
                </a>
                <a href="http://search.nicovideo.jp/search/#{bijin.category}" target="_blank" class="control" title="niconicoで#{bijin.category}を探す">
                    <i class="btn-niconico"></i>
                </a>
                <a href="http://ja.wikipedia.org/wiki/#{bijin.category}" target="_blank" class="control" title="Wikipediaで#{bijin.category}を探す">
                    <i class="btn-wikipedia"></i>
                </a>
            </div>
        </li>
        """

    $photos.imagesLoaded ->
        $loading.hide()
        relocatePhotos()
    @

today = ->
    date = new Date()
    year = date.getFullYear()
    month = date.getMonth() + 1
    day = date.getDate()
    month = "0" + month if month < 10
    day = "0" + day if day < 10
    "#{year}/#{month}/#{day}"

loadBijin = (count) ->
    $loading.fadeIn("fast")
    if bijin.timestamp is today()
        renderBijin bijin.data
    else
        xhr = new XMLHttpRequest()
        xhr.open "GET", "http://bjin.me/api/?format=json&count=#{count}&type=rand", true
        xhr.onreadystatechange = ->
            return unless xhr.readyState is 4
            bijinData = JSON.parse xhr.responseText
            renderBijin bijinData
            localStorage.setItem "bijin", JSON.stringify({data: bijinData, timestamp: today()})
        xhr.send()

loadSpecifiedBijin = (bijinId) ->
    xhr = new XMLHttpRequest()
    xhr.open "GET", "http://bjin.me/api/?type=detail&count=#{count}&format=json&id=#{bijinId}", true
    xhr.onreadystatechange = ->
        return unless xhr.readyState is 4
        bijinData = JSON.parse xhr.responseText

        if bijinData.length > 0
            $(".js-title").text "#{bijinData[0].category}の美人百景" if bijinData[0].category isnt ""
            $(".js-photos").find("li").remove()
            renderBijin bijinData
        else
            $loading.hide()
    xhr.send()

searchBijin = (category, callback) ->
    $loading.fadeIn "fast"

    if (bijinId = localStorage["category-" + encodeURIComponent(category)])?
        callback bijinId
        return

    xhr = new XMLHttpRequest()
    xhr.open "GET", "http://bjin.me/api/?type=search&count=1&format=json&query=#{category}", true
    xhr.onreadystatechange = ->
        return unless xhr.readyState is 4
        bijinId = JSON.parse(xhr.responseText)[0]?.id

        if !bijinId?
            $loading.hide()
            return

        localStorage.setItem("category-" + encodeURIComponent(category), bijinId)
        callback bijinId if callback?
    xhr.send()

$(".reload").click (e) ->
    e.preventDefault()
    localStorage.removeItem "bijin"
    $(".js-title").text "今日の美人百景"
    $(".js-photos").find("li").remove()
    loadBijin count

$(document).on "click", ".js-photo", (e) ->
    e.preventDefault()
    category = $(@).children("img").data("category")

    if category is ""
        $(@).hide()
        return

    searchBijin category, loadSpecifiedBijin

count = parseInt(localStorage.getItem("count") || count)
itemWidth = parseInt(localStorage.getItem("itemWidth") || itemWidth)
highQuality = !!(localStorage.getItem("high-quality") || highQuality)
bijin = JSON.parse(localStorage.getItem("bijin") || "{}")

$(".js-today").text today()

toggleControl(localStorage["controlVisible"] is "true")
$ctrlCol.show()
$ctrlCol.click ->
    localStorage["controlVisible"] = controlVisible = !(localStorage["controlVisible"] is "true")
    toggleControl controlVisible
    relocatePhotos()

if count is 0
    widthNum = $(window).width() / itemWidth
    heightNum = ($(window).height() - 72) / itemWidth
    count = widthNum * heightNum
    count = 15 if count < 15

loadBijin count
