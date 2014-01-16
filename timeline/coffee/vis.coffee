
root = exports ? this

Plot = () ->
  width = 700
  height = 400
  imgSize = 60
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 80, left: 40}
  xScale = d3.time.scale().range([0,width])

  colors = ["#ffffe5","#f7fcb9","#d9f0a3","#addd8e","#78c679","#41ab5d","#238443","#006837","#004529"]
  blues = ["#f7fbff","#deebf7","#c6dbef","#9ecae1","#6baed6","#4292c6","#2171b5","#08519c","#08306b"]
  oranges = ["#fff5eb","#fee6ce","#fdd0a2","#fdae6b","#fd8d3c","#f16913","#d94801","#a63603","#7f2704"]
  greens = ["#f7fcf5","#e5f5e0","#c7e9c0","#a1d99b","#74c476","#41ab5d","#238b45","#006d2c","#00441b"]
  
  yScale = d3.scale.linear().domain([0,10]).range([height,0])
  xValue = (d) -> d.date
  yValue = (d) -> parseFloat(d.y)

  parseTime = d3.time.format("%m-%d-%Y").parse
  # color = d3.scale.category10()
 
  xAxis = d3.svg.axis()
    .scale(xScale)
    .tickSize(-height)
    .tickFormat(d3.time.format('%b'))
    # .tickFormat(d3.time.format('%b %Y'))
    # https://github.com/mbostock/d3/wiki/Time-Formatting
  
  setupData = (rawData) ->
    rawData.forEach (d) ->
      d.date = parseTime(d.start)
    minDate = parseTime("02-01-2013")
    maxDate = parseTime("10-28-2013")
    # maxDate = d3.max(data, (d) -> d.values[d.values.length - 1].date)
    xScale.domain([minDate, maxDate])
    yScale.domain([0,rawData.length])
    
    rawData
      
  chart = (selection) ->
    selection.each (rawData) ->

      data = setupData(rawData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      g.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + (height + 40) +  ")")
        .call(xAxis)

      points = g.append("g").attr("id", "vis_points")
      
      update()

  update = () ->

    points.selectAll(".rect")
      .data(data).enter()
      .append("path")
      # .attr("d", (d,i) -> "M #{xScale(xValue(d))} #{yScale(i)} L #{width } #{yScale(i) - imgSize / 2} L #{width } #{yScale(i) + imgSize / 2} L #{xScale(xValue(d))} #{yScale(i) + imgSize / 3} ")
      .attr("d", (d,i) -> "M #{xScale(xValue(d))} #{yScale(i)} L #{xScale(xValue(d))} #{yScale(i)} L #{xScale(xValue(d))} #{yScale(i)} Z")
      .attr("class", "rect")
      .attr("fill", (d,i) -> colors[(data.length - 1) - i])

    points.selectAll(".point")
      .data(data).enter()
      .append("image")
      .attr("class", "point")
      .attr("xlink:href", (d) -> "img/heads/#{d.id}.png")
      .attr("height", imgSize)
      .attr("width", imgSize)
      .attr("x",-1 * imgSize * 2)
      .attr("y",-1 * imgSize * 2)
      .on "mouseover", (d,i) ->
        d3.select(this).attr("width", imgSize * 2)
          .attr("height", imgSize * 2)
          .attr("x", () -> xScale(xValue(d)) - imgSize )
          .attr("y", () -> yScale(i) - imgSize)
      .on "mouseout", (d,i) ->
        d3.select(this).attr("width", imgSize)
          .attr("height", imgSize)
          .attr("x", () -> xScale(xValue(d)) - imgSize / 2)
          .attr("y", () -> yScale(i) - imgSize / 2)



  chart.start = () ->
    points.selectAll(".rect").transition()
      .duration(1000)
      .delay((d,i) -> 1000 + (i * 100))
      .attr("d", (d,i) -> "M #{xScale(xValue(d))} #{yScale(i)} L #{width } #{yScale(i) - imgSize / 2} L #{width } #{yScale(i) + imgSize / 2} L #{xScale(xValue(d))} #{yScale(i) + imgSize / 3} Z")

    points.selectAll(".point").transition()
      .duration(1000)
      .delay((d,i) -> 100 * i)
      .attr("x", (d) -> xScale(xValue(d)) - imgSize / 2)
      .attr("y", (d,i) -> yScale(i) - imgSize / 2)

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
    plotData("#vis", data, plot)
    plot.start()

  queue()
    .defer(d3.csv, "data/starts.csv")
    .await(display)

