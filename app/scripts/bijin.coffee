bihyaku = bihyaku || {}
window.bihyaku = bihyaku
bihyaku.count = 0
bihyaku.itemWidth = if screen.width > 480 then 220 else 150
bihyaku.highQuality = true
bihyaku.bijin = {}
bihyaku.controlVisibleClass = "show"

MIN_COUNT = 18
$title = $(".js-title")
$photosContainer = $(".js-photos-container")
$photos = $(".js-photos")
$loading = $(".js-loading")
$ctrlCol = $(".js-control-collapse > i")
$loadMoreBtn = $(".js-loadmore")

relocatePhotos = ->
    options =
        offset: 1
        autoResize: true
        itemWidth: bihyaku.itemWidth
        flexibleWidth: true
        container: $photosContainer
    $photos.find("li").wookmark(options).show()

toggleControl = (controlVisible) ->
    bihyaku.controlVisibleClass = if controlVisible then "show" else ""
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
        thumbnail = if bihyaku.highQuality then hqThumbnail else lqThunbnail
        $photos.append """
        <li class="photo-container" style="display: none;">
            <a href="#{bijin.link}" target="_blank" data-id="#{bijin.id}" data-category="#{bijin.category}" class="control bjinme js-bjinme" title="Bjin.Meで詳細を見る">
                <i class="icon-heart"></i>
            </a>
            <a href="#" class="js-photo" title="#{bijin.category}の写真をもっと見る" >
                <img data-id="#{bijin.id}" data-category="#{bijin.category}" 
                    data-pub-data="#{bijin.pubDate}" data-hq-thumb="#{hqThumbnail}" 
                    data-lq-thumb="#{lqThunbnail}" src="#{thumbnail}">
            </a>
            <div class="js-controls controls #{bihyaku.controlVisibleClass}">
                <a href="https://www.google.co.jp/search?q=#{bijin.category}&safe=off&tbm=isch" target="_blank" data-id="#{bijin.id}" data-service="google" class="control" title="Google画像検索で#{bijin.category}を探す">
                    <i class="btn-google"></i>
                </a>
                <a href="http://www.youtube.com/results?search_query=#{bijin.category}" target="_blank" data-id="#{bijin.id}" data-service="youtube" class="control" title="YouTubeで#{bijin.category}を探す">
                    <i class="icon-youtube-play"></i>
                </a>
                <a href="http://search.nicovideo.jp/search/#{bijin.category}" target="_blank" data-id="#{bijin.id}" data-service="niconico" class="control" title="niconicoで#{bijin.category}を探す">
                    <i class="btn-niconico"></i>
                </a>
                <a href="http://ja.wikipedia.org/wiki/#{bijin.category}" target="_blank" data-id="#{bijin.id}" data-service="wikipedia" class="control" title="Wikipediaで#{bijin.category}を探す">
                    <i class="btn-wikipedia"></i>
                </a>
            </div>
        </li>
        """

    $photos.imagesLoaded ->
        $loading.hide()
        relocatePhotos()
        $loadMoreBtn.text("もっと見たい").removeClass("pure-button-disabled").show()
    @

today = ->
    date = new Date()
    year = date.getFullYear()
    month = date.getMonth() + 1
    day = date.getDate()
    month = "0" + month if month < 10
    day = "0" + day if day < 10
    "#{year}/#{month}/#{day}"

handleError = (e) ->
    console?.err? e

loadUnspecifiedBijin = (count = bihyaku.count, doAppend = false) ->
    if !doAppend
        $loadMoreBtn.hide()
        $photos.find("li").remove()
        $photosContainer.height "auto"
    else
        $loadMoreBtn.text("必死に探してます").addClass("pure-button-disabled").show()

    document.title = "美人百景"
    $title.text "今日の美人百景"
    $loading.fadeIn("fast") if $loading.is ":hidden"

    if !doAppend and bihyaku.bijin?.timestamp is today()
        renderBijin bihyaku.bijin.data
    else
        xhr = new XMLHttpRequest()
        xhr.open "GET", "http://bjin.me/api/?format=json&count=#{count}&type=rand", true
        xhr.onreadystatechange = ->
            return unless xhr.readyState is 4
            bijinData
            try
                bijinData = JSON.parse xhr.responseText
                history.pushState {}, "", "/" if window.history?.pushState? and location.pathname isnt "/"
                renderBijin bijinData
                bihyaku.bijin = JSON.stringify({data: bijinData, timestamp: today()})
                localStorage.setItem "bijin", bihyaku.bijin if !doAppend
            catch e
                handleError e
        xhr.send()

loadSpecifiedBijin = (bijinId, count = bihyaku.count, doAppend = false) ->
    if !doAppend
        $loadMoreBtn.hide()
        $photos.find("li").remove()
        $photosContainer.height "auto"
    else
        $loadMoreBtn.text("必死に探してます").addClass("pure-button-disabled").show()
    $loading.fadeIn("fast") if $loading.is ":hidden"

    xhr = new XMLHttpRequest()
    xhr.open "GET", "http://bjin.me/api/?type=detail&count=#{count}&format=json&id=#{bijinId}", true
    xhr.onreadystatechange = ->
        return unless xhr.readyState is 4
        bijinData
        try
            bijinData = JSON.parse xhr.responseText
        catch e
            handleError e

        if bijinData?.length > 0
            bijin = bijinData[0]
            $title.text document.title = "#{bijin.category}の美人百景" if bijin.category isnt ""
            history.pushState {id: bijinId, category: bijin.category}, "", "/bijin/#{bijinId}" if window.history?.pushState? and location.pathname isnt "/bijin/#{bijinId}"
            renderBijin bijinData
        else
            $loading.hide()
    xhr.send()

loadBijin = (count = bihyaku.count, doAppend = false) ->
    bijinId = parseBijinIdInPath()
    if bijinId?
        loadSpecifiedBijin bijinId, count, doAppend
    else
        loadUnspecifiedBijin count, doAppend

searchBijin = (category, callback) =>
    $loading.fadeIn "fast"

    if (bijinId = localStorage["category-" + encodeURIComponent(category)])?
        callback bijinId
        return

    xhr = new XMLHttpRequest()
    xhr.open "GET", "http://bjin.me/api/?type=search&count=1&format=json&query=#{category}", true
    xhr.onreadystatechange = ->
        return unless xhr.readyState is 4
        bijinId
        try
            bijinId = JSON.parse(xhr.responseText)[0]?.id
        catch e
            handleError e

        if !bijinId?
            $loading.hide()
            return

        localStorage.setItem("category-" + encodeURIComponent(category), bijinId)
        callback bijinId if callback?
    xhr.send()

parseBijinIdInPath = ->
    paths = location.pathname.split "/"
    paths.length is 3 and paths[1] is "bijin" and /\d+/.test paths[2]
    paths[2] || undefined

bihyaku.count = parseInt(localStorage.getItem("count") || bihyaku.count)
bihyaku.itemWidth = parseInt(localStorage.getItem("itemWidth") || bihyaku.itemWidth)
if bihyaku.count is 0
    widthNum = $(window).width() / bihyaku.itemWidth
    heightNum = ($(window).height() - 72) / bihyaku.itemWidth
    bihyaku.count = ~~(widthNum * heightNum)
    bihyaku.count = MIN_COUNT if bihyaku.count < MIN_COUNT

bihyaku.highQuality = !!(localStorage.getItem("high-quality") || bihyaku.highQuality)
bihyaku.bijin = JSON.parse(localStorage.getItem("bijin") || "{}")

$(".js-today").text today()

toggleControl(localStorage["controlVisible"] is "true")
$ctrlCol.show()
$ctrlCol.click (e) ->
    e.preventDefault()
    localStorage["controlVisible"] = controlVisible = !(localStorage["controlVisible"] is "true")
    toggleControl controlVisible
    gase? "controlVisible", "click", controlVisible
    relocatePhotos()

$(".reload").click (e) ->
    e.preventDefault()
    gase? "reload", "click", "reload"
    localStorage.removeItem "bijin"
    bihyaku.bijin = {}
    loadBijin bihyaku.count, false

$(document).on "click", ".js-bjinme", (e) ->
    id = $(@).data "id"
    category = $(@).data "category"
    gase? "bjinme", "click", category, parseInt(id, 10)

$(document).on "click", ".js-controls a", (e) ->
    id = $(@).data "id"
    service = $(@).data "service"
    gase? "controls", "click", service, parseInt(id, 10)

$(document).on "click", ".js-photo", (e) ->
    e.preventDefault()
    $img = $(@).children "img"
    id = $img.data "id"
    category = $img.data "category"
    gase? "photo", "click", category, parseInt(id, 10)

    if category is ""
        $(@).hide()
        return

    searchBijin category, loadSpecifiedBijin
    # setTimeout (-> window.scroll 0, 0), 0

$(document).on "click", ".js-loadmore", (e) ->
    e.preventDefault()
    loadBijin bihyaku.count, true
    gase? "loadmore", "click", location.pathname

$("#js-search-field").autocomplete
    source: (req, res) ->
        regex = new RegExp req.term, "i"
        $.getJSON "/data/bijin_list.json", (list) ->
            res $.map(list, (item) ->
                if regex.test item.name
                    return {
                        label: item.name
                        value: item.id
                    }
                )
    focus: (event, ui) ->
        $("#js-search-field").val ui.item.label
        return false
    select: (event, ui) ->
        $("#js-search-field").val ui.item.label
        loadSpecifiedBijin ui.item.value
        gase? "search", "click", ui.item.label
        return false

popped = window.history.state?
initialUrl = location.href
$(window).on "popstate", (e) =>
    initialPop = !popped and location.href is initialUrl
    popped = true
    loadBijin bihyaku.count, false if !initialPop

loadBijin()