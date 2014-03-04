
StackedArea = () ->
  width = 20
  height = 60
  margin = {top: 0, right: 0, bottom: 0, left: 0}
  user_id = -1
  vis = null
  svgs = null
  pre = null
  previews = null
  allData = []
  data = []
  scaleFactor = 8

  h = d3.scale.linear()

  weight = (d) -> d.weighted_count
  maxColors = 20
  maxWeight = 0.85

  filterData = (rawData) ->
    if user_id < 0
      user_id = rawData[0].id
    data = rawData.filter (d) -> d.id == user_id
    data = data[0]
    data

  restrictData = (filteredData) ->
    sortedData = filteredData.sort((a,b) -> weight(b) - weight(a))
    restricted = []
    totalWeight = sortedData.map((d) -> weight(d)).reduce((p,c) -> p + c)
    curWeight = 0

    for d in sortedData
      curWeight += weight(d)
      restricted.push(d)
      if (curWeight / totalWeight) >= maxWeight
        break

    h.domain([0, curWeight])

    restricted

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      pre = d3.select(this).select("#previews")
        .selectAll(".preview").data(data)

      # create the svg elements
      pre.enter()
        .append("div")
        .attr("class", "preview")
        .attr("width", width + "px")
        .attr("height", height + "px")

      svgs = pre.append("svg")
        .attr("width", width)
        .attr("height", height)

      previews = svgs.append("g")

      previews.each(drawChart)

      previews.append("rect")
        .attr("width", width)
        .attr("height", height)
        .attr("fill-opacity", 1)
        .attr("class", "filler")
        .attr("fill", "white")
        .on("click", showDetail)
      

  drawChart = (d,i) ->
  # update = () ->
    h.range([0, height])
    # data = filterData(allData)
    cData = restrictData(d.colors)
    # vis.selectAll(".stack").data([]).exit().remove()
    #
    base = d3.select(this)
    vis = base.append("g")
    
    v = vis.selectAll(".stack")
      .data(cData)

    v.enter().append("rect")
      .attr("width", width)
      .attr("x", 0)
      .attr("class", "stack")

    totalHeight = 0.0
    v.attr "y", (d,i) ->
      mheight = h(weight(d))
      myY = totalHeight
      totalHeight += mheight
      myY
    .attr "height", (d,i) ->
      mheight = h(weight(d))
      mheight
    .attr("fill", (d) -> d.rgb_string)

    v.exit().remove()
      
  # ---
  # Shows the detail view for a given element
  # This works by appending a copy of the graph
  # to the 'detail' svg while switching the
  # detail section to visible
  # ---
  showDetail = (d,i) ->
    # switch the css on which divs are hidden
    # toggleHidden(true)
    
    detailView = d3.select("#detail_view")

    # clear any existing detail view
    detailView.selectAll('.main').remove()

    # bind the single element to be detailed to the 
    # detail view's group
    detailG = detailView.selectAll('g').data([d]).enter()

    # create a new group to display the graph in
    main = detailG.append("g")
      .attr("class", "main")

    # draw graph just like in the initial creation
    # of the small multiples
    main.each(drawChart)


    # setup click handler to hide detail view once
    # graph or detail panel is clicked
    main.on("click", () -> hideDetail(d,i))
    d3.select("#detail").on("click", () -> hideDetail(d,i))
   
    # Here is the code responsible for the lovely zoom
    # affect of the detail view
    
    # getPosition is a helper function to
    # return the relative location of the graph
    # to be viewed in the detail view
    pos = getPosition(i)
    # scrollTop returns the number of pixels
    # hidden on the top of the window because of
    # the window being scrolled down
    # http://api.jquery.com/scrollTop/
    scrollTop = $(window).scrollTop()

    # first we move our (small) detail graph to be positioned over
    # its preview version
    main.attr('transform', "translate(#{pos.left},#{pos.top - scrollTop})")
    # then we use a transition to center the detailed graph and scale it
    # up to be bigger
    main
      .attr("opacity", 1e-6)
      .attr('transform', "translate(#{300},#{100}) scale(#{scaleFactor})")

    main.transition()
      .duration(200)
      .attr("opacity", 1)
      .each("end", () -> hideDetail(d,i))

  showSmall = (i) ->
    previews.select(".filler").filter((d,e) -> e == i).remove()
      # .attr("fill-opacity", (d,e) -> if e == i then 0 else 1)

  # ---
  # This function shrinks the detail view back from whence it came
  # ---
  hideDetail = (d,i) ->
    # see showDetail for... details
    pos = getPosition(i)
    scrollTop = $(window).scrollTop()

    # Use transition to move the detail panel back 
    # down to its preview's location
    # The view also shrinks back to its preview size
    # because d3's transition can tween between the 
    # scale it had, and the lack of scale here.
    d3.selectAll('#detail_view .main').transition()
      .delay(500)
      .duration(400)
      .attr('transform', "translate(#{pos.left},#{pos.top - scrollTop})")
      .each 'end', () ->
        # toggleHidden(false)
        showSmall(i)


  chart.add = () ->
    current = getRandomInt(0, data.length - 1)
    previews.each((d,i) -> if current == i then showDetail(d,i))
    # current += 1

  # ---
  # Toggles hidden css between the previews and detail view divs
  # if show is true, the detail view is shown
  # ---
  toggleHidden = (show) ->
    d3.select("#previews").classed("hidden", show).classed("visible", !show)
    d3.select("#detail").classed("hidden", !show).classed("visible", show)


  # ---
  # Updates domains for scales used in bar charts
  # expects 'data' to be accessible and set to our
  # data.
  # ---
  setScales = () ->
    yMax = d3.max(data, (d) -> d3.max(d.values, (e) -> e.value))
    # this scale is expanded past its max to provide some white space
    # on the top of the bars
    yScale.domain([0,yMax + 500000])

    names = data[0].values.map (d) -> d.name
    xScale.domain(names)
    colorScale.domain(names)

  # ---
  # Helper function to return the position
  # of a preview graph at index i
  # ---
  getPosition = (i) ->
    el = $('.preview')[i]
    # http://api.jquery.com/position/
    pos = $(el).position()
    pos

  chart.updateDisplay = (_) ->
    user_id = _
    update()
    chart

  chart.id = (_) ->
    if !arguments.length
      return user_id
    user_id = _
    chart

  chart.weight = (_) ->
    if !arguments.length
      return weight
    weight = _
    chart

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  return chart



$ ->
  stacked_weight = StackedArea()
  intervalId = 1

  display = (error, data) ->
   shuffle(data)
   data = data[0..250]
   d3.select("#vis")
     .datum(data)
     .call(stacked_weight)
   intervalId = window.setInterval(animate, 1200)

  animate = () ->
    stacked_weight.add()

  stopPlot = () ->
    clearInterval(intervalId)

  queue()
    .defer(d3.json, "data/user_colors.json")
    .await(display)


