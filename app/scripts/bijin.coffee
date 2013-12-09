window.bihyaku = bihyaku = window.bihyaku || {}
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
    $title.text "今日の"
    $loading.fadeIn("fast") if $loading.is ":hidden"

    if !doAppend and bihyaku.bijin?.timestamp is today()
        renderBijin bihyaku.bijin.data
        setTimeout (-> loadRelatedContents $.map(bihyaku.bijin.data, (data) -> data.category)), 600
    else
        $.ajax
            url: "http://bjin.me/api/?format=json&count=#{count}&type=rand"
        .done (json) ->
            try
                bijinData = JSON.parse json
                history.pushState {}, "", "/" if window.history?.pushState? and location.pathname isnt "/"
                renderBijin bijinData
                bihyaku.bijin = JSON.stringify({data: bijinData, timestamp: today()})
                localStorage.setItem "bijin", bihyaku.bijin if !doAppend
                setTimeout (-> loadRelatedContents $.map(bijinData, (data) -> data.category)), 600
            catch e
                handleError e

loadSpecifiedBijin = (bijinId, count = bihyaku.count, doAppend = false) ->
    if !doAppend
        $loadMoreBtn.hide()
        $photos.find("li").remove()
        $photosContainer.height "auto"
    else
        $loadMoreBtn.text("必死に探してます").addClass("pure-button-disabled").show()

    $loading.fadeIn("fast") if $loading.is ":hidden"

    $.ajax
        url: "http://bjin.me/api/?type=detail&count=#{count}&format=json&id=#{bijinId}"
    .done (json) ->
        bijinData
        try
            bijinData = JSON.parse json
        catch e
            handleError e

        if bijinData?.length > 0
            bijin = bijinData[0]
            if bijin.category isnt ""
                $title.text "#{bijin.category}の"
                document.title = "#{$title.text()}美人百景"
            history.pushState {id: bijinId, category: bijin.category}, "", "/bijin/#{bijinId}" if window.history?.pushState? and location.pathname isnt "/bijin/#{bijinId}"
            renderBijin bijinData
            setTimeout (-> loadRelatedContents [bijin.category]), 600
        else
            $loading.hide()
    .fail ->
        $loading.hide()

loadBijin = (count = bihyaku.count, doAppend = false) ->
    bijinId = parseBijinIdInPath()
    if bijinId?
        loadSpecifiedBijin bijinId, count, doAppend
    else
        loadUnspecifiedBijin count, doAppend

loadRelatedContents = (categories) ->
    $(".js-related").find("li").remove()
    category = categories.join " | "
    $.ajax
        url: "http://api.search.nicovideo.jp/api/"
        type: "POST"
        data: """
                {
                   "query":"#{category}",
                   "service":["video", "live", "book"],
                   "search":["tags"],
                   "join":[
                      "cmsid",
                      "title",
                      "thumbnail_url",
                      "community_icon"
                   ],
                   "filters":[{
                      "type":"equal",
                      "field":"ss_adult",
                      "value":false
                   }],
                   "sort_by":"_explore",
                   "from":0,
                   "size":20,
                   "issuer":"bihyaku",
                   "reason":"ma9"
                }
            """
    .always (data) ->
        chunks = data?.responseText?.split "\n"
        $.map chunks, (chunk) ->
            json = JSON.parse chunk if chunk isnt ""
            if json?.type is "hits" and json.values?
                renderContents json.values
                return

renderContents = (contents) ->
    $container = $(".js-related-contents")
    $container.empty()
    for content in contents
        $container.append """
        <li class="related-content-container">
            <a href="#{getRelatedContentLink content}" class="js-related-content" target="_blank">
                <img class="related-content-thumbnail" src="#{content.thumbnail_url || content.community_icon}">
                <p class="related-content-title">#{getRelatedContentTitle content}</p>
            </a>
        </li>
        """

getRelatedContentLink = (content) ->
    switch content.service
        when "live" then "http://live.nicovideo.jp/watch/#{content.cmsid}"
        when "book" then "http://seiga.nicovideo.jp/watch/#{content.cmsid}"
        else "http://www.nicovideo.jp/watch/#{content.cmsid}"

getRelatedContentTitle = (content) ->
    switch content.service
        when "live" then "[Live] #{content.title}"
        when "book" then "[Book] #{content.title}"
        else "[Video] #{content.title}"

searchBijin = (category, callback) =>
    $loading.fadeIn "fast"

    if (bijinId = localStorage["category-" + encodeURIComponent(category)])?
        callback bijinId
        return

    $.ajax
        url: "http://bjin.me/api/?type=search&count=1&format=json&query=#{category}"
    .done (json) ->
        bijinId
        try
            bijinId = JSON.parse(json)[0]?.id
        catch e
            handleError e

        if !bijinId?
            $loading.hide()
            return

        localStorage.setItem("category-" + encodeURIComponent(category), bijinId)
        callback bijinId if callback?
    .fail ->
        $loading.hide()

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
        res $.map(bihyaku.bijinList, (item) ->
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

$("#expand").sidr
    name: "sidr"
    side: "right"
    source: ->
        """
        <header>
            <h1 class="related-title"><i class="btn-niconico"></i>関連コンテンツ</h1>
        </header>
        <ul class="js-related-contents"></ul>
        """
    onOpen: ->
        gase? "related", "click"

loadBijin()