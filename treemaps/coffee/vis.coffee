
root = exports ? this

Plot = () ->
  # colors = {"me":"#8D040C","bap":"#322209","pres":"#3D605C","cat":"#2E050B","con":"#4B6655","epi":"#C84914","lut":"#C6581B","chr":"#87090D","oth":"#300809"}
  #colors = {"me":"url(#lines_red)","bap":"#3e290e","pres":"#3a5b57","cat":"#30050c","con":"url(#lines_blue)","epi":"#c0410f","lut":"#C6581B","chr":"#85090d","oth":"#310909"}
  names = [{"code":"me",   "name":"Methodist"},
           {"code":"bap",  "name":"Baptist"},
           {"code":"pres", "name":"Presbyterian"},
           {"code":"cat",  "name":"Roman Catholic"},
           {"code":"con",  "name":"Congregational"},
           {"code":"epi",  "name":"Episcopal"},
           {"code":"lut",  "name":"Lutheran"},
           {"code":"chr",  "name":"Christian"},
           {"code":"dut",  "name":"Dutch Reformed"},
           {"code":"uni",  "name":"Universalist"},
           {"code":"mor",  "name":"Mormon"},
           {"code":"oth",  "name":"All other Denominations"}
          ]
  colors = {"me":"url(#lines_red)","bap":"#614e23","pres":"#5c7e7d","cat":"#551521","con":"url(#lines_blue)","epi":"#d96d2c","lut":"url(#lines_orange)","chr":"#ac2028","dut":"#9d8354", "uni":"url(#lines_purple)", "mor":"#150912","oth":"#551b1a"}
  background = "#a89888"
  width = 1100
  height = 900
  bigSize = 300
  littleSize = 130
  padding = 40
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)
  treeScale = d3.scale.linear().domain([0,100]).range([0,littleSize])
  treemap = d3.layout.treemap()
    .sort((a,b) -> b.index - a.index)
    .children((d) -> d.churches)
    .value((d) -> d.percent)
    .mode('slice')

  processData = (rawData) ->
    rawData.forEach (tre,i) ->
      # the big square takes up two little squares
      tre.index = if tre.size == 'little' then i + 1 else i
      tre.row = if tre.size == 'little' then Math.floor(tre.index / 6) + 1 else 0
      tre.col = tre.index % 6
      tre.realSize = if tre.size == 'little' then littleSize else bigSize
      # this is to keep them in order
      # cause i'm too lazy to use stack
      tre.churches.forEach (c,i) ->
        c.index = i
    rawData

  addKey = () ->
    keyWidth = 50
    keyHeight = 12
    keyPadding = 1
    keys = points.selectAll(".key")
      .data(names)
    keyG = keys.enter().append("g")
      .attr("class", "key")
      .attr("transform", (d,i) -> "translate(#{((bigSize) + (padding + littleSize) * 4) - keyWidth},#{i * (keyHeight + keyPadding)})")
    keyG.append("rect")
      .attr("width", keyWidth)
      .attr("height", keyHeight)
      .attr("fill", (d) -> colors[d.code])

    keyG.append("text")
      .attr("x", -120)
      .attr("dy", (keyHeight ))
      .text((d) -> d.name)

  addTitle = () ->
    titles = ["chart", "showing the ratio of",
              "church accommodation",
              "to the total population over 10 years of age",
              "with the proportion of such church accommodation furnished by each of",
              "the largest four denominations within each state and by each of",
              "the largest eight denominations within the united states."]
    g = points.append("g")
      .attr("class", "title")
      .attr("transform", "translate(#{width / 2}, 10)")

    g.selectAll("text")
      .data(titles)
      .enter().append("text")
      .attr("class", (d,i) -> if i == 2 then "big-title" else if i > 2 then "bottom-title" else "top-title")
      .text((d) -> d.toUpperCase())
      .attr("text-anchor", "middle")
      .attr("y", (d,i) -> 20 * i + if i >= 2 then 10 else 0)

  chart = (selection) ->
    selection.each (rawData) ->

      data = processData(rawData)
      console.log(data)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")

      defs = svg.append("defs")
      hatch1 = defs.append("pattern")
        .attr("id", "lines_red")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch1.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch1.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "red")
        .style("stroke-width", 3.6)
      hatch2 = defs.append("pattern")
        .attr("id", "lines_blue")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch2.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch2.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "#4B6655")
        .style("stroke-width", 3.6)

      hatch3 = defs.append("pattern")
        .attr("id", "lines_orange")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch3.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch3.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "#C6581B")
        .style("stroke-width", 4.8)

      hatch4 = defs.append("pattern")
        .attr("id", "lines_purple")
        .attr("patternUnits", "userSpaceOnUse")
        .attr("patternTransform", "rotate(#{-220})")
        .attr("x", 0)
        .attr("y", 2)
        .attr("width", 5)
        .attr("height", 3)
        .append("g")
      hatch4.append("rect")
        .attr("fill", "white")
        .attr("width", 5)
        .attr("height", 3)
      hatch4.append("path")
        .attr("d", "M0 0 H 5")
        .style("fill", "none")
        .style("stroke", "#77393c")
        .style("stroke-width", 4.8)

      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->

    addKey()
    addTitle()

    tree = points.selectAll('.tree')
      .data(data).enter().append("g")
      .attr("class","tree")
      .attr "transform", (d,i) ->
        top = d.row * (padding + littleSize)
        "translate(#{(d.col) * (littleSize + padding)},#{top})"

    tree.append("rect")
      .attr("width", (d) -> d.realSize)
      .attr("height", (d) -> d.realSize)
      .attr("x", 0)
      .attr('y', 0)
      .attr('fill', background)

    tree.append("text")
      .attr("text-anchor", "middle")
      .attr("x", (d) -> d.realSize / 2)
      .attr("y", (d) -> d.realSize)
      .attr('dy', 18)
      .text((d) -> d.name.toUpperCase())


    treeG = tree.append("g")
      .attr "transform", (d) ->
        scale = d.known / 100.0
        trans = (d.realSize - (d.realSize * scale)) / 2
        console.log(trans)
        "translate(#{trans},#{trans})scale(#{scale})"

    treeG.selectAll(".slice")
      .data((d) -> treemap.size([d.realSize, d.realSize])(d)).enter()
      .append("rect")
      .attr('class', (d) -> "slice #{d.name}")
      .attr("x", (d) -> d.x)
      .attr("y", (d) -> d.y)
      .attr("width", (d) -> Math.max(0, d.dx))
      .attr("height", (d) -> Math.max(0, d.dy))
      .attr("fill", (d) -> colors[d.name])



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

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Plot()
  display = (error, data) ->
    console.log(error)
    plotData("#vis", data, plot)

  queue()
    .defer(d3.json, "data/treemap.json")
    .await(display)

