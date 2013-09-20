FETCH_BIJIN_NUM = 1136
bijinId = 1

fetchBijinInfo = (bijinId) ->
    $.when(
        $.ajax "http://bjin.me/api/?type=detail&count=1&format=json&id=" + bijinId
    ).done (detailJson) ->
        try
            console.log bijinId + "\t" + JSON.parse(detailJson)[0].category
        setTimeout ->
            fetchBijinInfo ++bijinId if bijinId < FETCH_BIJIN_NUM
        , 500 + Math.random() * 3000

fetchBijinInfo bijinId